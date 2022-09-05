# frozen_string_literal: true

class MatchCensusToPersonRecordJob < ApplicationJob
  include FastMemoize

  def perform(year, id)
    @census_record = CensusRecord.for_year(year).find(id)
    @person_record = probable_match || generate_person_record
    return unless @person_record.persisted?

    @census_record.person = @person_record
    @census_record.save
  end

  def possible_matches
    Person.with_census_records
          .where(sex: @census_record.sex, last_name: @census_record.last_name, first_name: @census_record.first_name)
          .order(:first_name, :middle_name)
  end
  memoize :possible_matches

  def probable_match
    return if possible_matches.blank?

    record = @census_record
    probables = []
    possible_matches.each do |match|
      probables << match if match.similar_in_age?(record)
    end

    if probables.any?
      return probables.first if probables.size == 1

      probables.each do |match|
        score = 0
        match.census_records.each do |match_record|
          score += 1 if match_record.race == record.race
          score += 1 if match_record.building_id == record.building_id
          score += 1 if match_record.relation_to_head == record.relation_to_head
          score += 1 if match_record.profession == record.profession
          match_record.fellows.each do |match_record_fellow|
            record.fellows.each do |fellow|
              if fellow.first_name == match_record_fellow.first_name && fellow.relation_to_head == match_record_fellow.relation_to_head
                score += 1
              end
            end
          end
          match.match_score = score
        end
      end
      probables.sort_by(&:match_score).last
    end
  end

  def generate_person_record
    @person_record = Person.new
    %i[name_prefix name_suffix first_name middle_name last_name sex race].each do |attr|
      @person_record[attr] = @census_record[attr]
    end
    @person_record.save
    @person_record
  end
end
