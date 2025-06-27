import {configureStore}  from "@reduxjs/toolkit"
import {actorReducer,authReducer,userNameReducer} from "./newReducer"

// this is another object style they'll be exported as part of an object still{}.
export const store = configureStore({
    // check the right way of assigning a reducer whether its an array or an object.
    // found out it should be an object, instead of an array.
    reducer: {
        userName : userNameReducer,
        authClient : authReducer,
        actor: actorReducer
        // surprisingly enough its this attribute names defined in the reducer attribute that actually get used by the components, since its this store that's provided to them.
    }
})

export type RootState = ReturnType<typeof store.getState>

export type AppDispatch = typeof store.dispatch

