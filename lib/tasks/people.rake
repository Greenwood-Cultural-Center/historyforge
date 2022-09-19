namespace :people do
  task cultivate: :environment do
    ActiveRecord::Base.connection.execute <<~SQL
      DELETE FROM people WHERE id IN(
          SELECT people.id FROM people LEFT OUTER JOIN people_photographs ON people_photographs.person_id=people.id
            LEFT OUTER JOIN census_1880_records ON people.id=census_1880_records.person_id
            LEFT OUTER JOIN census_1900_records ON people.id=census_1900_records.person_id
            LEFT OUTER JOIN census_1910_records ON people.id=census_1910_records.person_id
            LEFT OUTER JOIN census_1920_records ON people.id=census_1920_records.person_id
            LEFT OUTER JOIN census_1930_records ON people.id=census_1930_records.person_id
            LEFT OUTER JOIN census_1940_records ON people.id=census_1940_records.person_id
            LEFT OUTER JOIN census1950_records ON people.id=census1950_records.person_id
            WHERE people_photographs.photograph_id IS NULL AND census_1880_records.id IS NULL AND census_1900_records.id IS NULL
              AND census_1910_records.id IS NULL AND census_1920_records.id IS NULL AND census_1930_records.id IS NULL
              AND census_1940_records.id IS NULL AND census1950_records.id IS NULL
          )
    SQL
  end
  task connect: :environment do
    CensusYears.each do |year|
      CensusRecord.for_year(year).ids.each do |id|
        MatchCensusToPersonRecordJob.new.perform(year, id)
      end
      CensusRecord.for_year(year).find_each &:save
    end
  end
  task age: :environment do
    Person.where(birth_year: nil).each do |person|
      person.estimate_birth_year
      person.save
    end
    Person.where(pob: nil).each do |person|
      person.estimate_pob
      person.save
    end
  end
end
