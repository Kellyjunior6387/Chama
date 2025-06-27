import { useEffect, useState } from "react"
import { Error, Notification } from "./notifications"

// create a chama
export function Create(){
    const [notification,setNotification] = useState<JSX.Element>(<></>)
    const [chamaName,setChamaName] = useState<string>("")
    const [notificationMessage,setNotificationMessage] = useState<string>("")
    const [errorMessage,setErrorMessage] = useState<string>("")
    const [notCounter,setNotCounter] = useState<number>(0)
    const [errCounter,setErrCounter] = useState<number>(0)
    const [authenticated,setAuthenticated] = useState<boolean>(false)


    useEffect(function(){
        if(notificationMessage != ""){
            setNotification(<Notification counter={notCounter} message={notificationMessage} />)
        }
    },[notCounter])

    useEffect(function(){
        if(errorMessage != ""){
            setNotification(<Error counter={errCounter} message={errorMessage} />)
        }
    },[errCounter])
    


    let createHandler = function(e:any){
        e.preventDefault()
        setErrorMessage("internal server error")
        setErrCounter(prev => prev + 1)
    }

    let chamaChange = function(e:any){
        e.preventDefault()
        let nameKeyed = e.target.value.toLowerCase()
        setChamaName(nameKeyed)
    }

    return(
        <div className="w-full h-screen flex flex-col justify-center select-none" >
            {notification}
            <h1 className="text-xl font-bold text-white mb-4 text-center">welcome to chama enter a group name to create</h1>
            <input type="text" className="w-5/6 sm:w-3/4 md:w-1/2 h-12 px-6 py-4 bg-white text-blue-600 mx-auto mb-8 rounded-lg" placeholder="name e.g Wamama wa " onChange={chamaChange} value={chamaName}/>
            <button className="px-6 py-4 w-4/6 sm:w-2/3 md:w-1/2 rounded-lg bg-blue-600 mx-auto font-bold" onClick={createHandler}>create</button>  
        </div>
    )
}