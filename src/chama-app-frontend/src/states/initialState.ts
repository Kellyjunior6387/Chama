
type InitialStateType = {
    userName: string,
    authClient: any,
    actor: any
}

const initialState:InitialStateType = {
    userName: "",
    authClient:null,
    actor:null
}


export {initialState}