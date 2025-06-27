import {createSlice} from "@reduxjs/toolkit"
import { initialState } from "./initialState"


// createSlice takes an object.
// everything in it has a key and value including initial state, if you investigate it is an object and so it can be added into the createSlice directly.
// also remember to export the slice by itself
// I actually dont know where the likeSliice imported as a whole is going to be used but just import it.

// so I actually found out that the useSelector is the one to use this exported slice since it uses the name defined inside it to access it
export const actorSlice = createSlice({
    name : "actor",
    initialState: initialState.actor,
    reducers : {
        // these attributes are basically the action names, each of them has a minireducer of its own. Though the advantage is that it works from the same state.
        // another thing is that you don't have to make a copy as before in the initial redux reducers of the old days.
        addActor : (state,action) => {
            return action.payload
        },
        // remember that the reducers can as well take the action parameter for the payloads that may be passed
        deleteActor : (state,action) => {
            // accessed through the action.
            return null
        },
        updateActor : (state,action) => {
            // takes two parameters
            return action.payload
        }
    }
    
})

export const userNameSlice = createSlice({
    name : "userName",
    initialState: initialState.userName,
    reducers : {
        // these attributes are basically the action names, each of them has a minireducer of its own. Though the advantage is that it works from the same state.
        // another thing is that you don't have to make a copy as before in the initial redux reducers of the old days.
        addUserName : (state,action) => {
            return action.payload
        },
        // remember that the reducers can as well take the action parameter for the payloads that may be passed
        deleteUserName : (state,action) => {
            // accessed through the action.
            return ""
        },
        updateUserName : (state,action) => {
            // takes two parameters
            return action.payload
        }
    }
    
})

export const authClientSlice = createSlice({
    name : "authClient",
    initialState: initialState.authClient,
    reducers : {
        // these attributes are basically the action names, each of them has a minireducer of its own. Though the advantage is that it works from the same state.
        // another thing is that you don't have to make a copy as before in the initial redux reducers of the old days.
        addAuthClient : (state,action) => {
            return action.payload
        },
        // remember that the reducers can as well take the action parameter for the payloads that may be passed
        deleteAuthClient : (state,action) => {
            // accessed through the action.
            return null
        },
        updateAuthClient : (state,action) => {
            // takes two parameters
            return action.payload
        }
    }
    
})


export const {addActor,deleteActor,updateActor} = actorSlice.actions // going to be used as actions by the reacy components themselves
export const actorReducer = actorSlice.reducer // this is what the store actually uses.

export const {addUserName,deleteUserName,updateUserName} = userNameSlice.actions // going to be used as actions by the reacy components themselves
export const userNameReducer = userNameSlice.reducer // this is what the store actually uses.

export const {addAuthClient,deleteAuthClient,updateAuthClient
    
} = authClientSlice.actions // going to be used as actions by the reacy components themselves
export const authReducer = authClientSlice.reducer // this is what the store actually uses.

