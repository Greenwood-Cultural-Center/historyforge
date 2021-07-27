import axios from 'axios'
import buildParams from "../forge/buildParams";

const csrfMetaTag = document.getElementsByName('csrf-token')[0]
const token = csrfMetaTag ? csrfMetaTag.getAttribute('content') : null
if (token) {
    axios.defaults.headers.common['X-CSRF-Token'] = token
    axios.defaults.headers.common['Accept'] = 'application/json'
}

export const forgeMiddleware = store => next => (incomingAction) => {
    if (incomingAction.type === 'BUILDING_MOVE') {
        const url = document.location.pathname
        axios.patch(url, {
            building: incomingAction.point
        }).then(() => {
            store.dispatch({type: 'BUILDING_MOVED', point: incomingAction.point})
        })
    } else if(incomingAction.type === 'BUILDING_SELECT') {
        const url = `/buildings/${incomingAction.id}.json`
        axios.get(url, { params: buildParams(incomingAction.params)}).then(json => {
            store.dispatch({type: 'BUILDING_SELECTED', building: json.data.data})
        })
    } else {
        next(incomingAction)
    }
}

