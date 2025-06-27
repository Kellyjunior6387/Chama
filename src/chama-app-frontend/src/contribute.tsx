import { useEffect, useState } from "react"
import { Error, Notification } from "./notifications"


export function Contribute(){
    const [notification,setNotification] = useState<JSX.Element>(<></>)
    const [chamaContribution,setChamaContribution] = useState<string>("")
    const [chamaName,setChamaName] = useState<string>("wamama soko")
    const [notificationMessage,setNotificationMessage] = useState<string>("")
    const [poolAmount,setPoolAmount] = useState<number>(100)
    const [errorMessage,setErrorMessage] = useState<string>("")
    const [notCounter,setNotCounter] = useState<number>(0)
    const [errCounter,setErrCounter] = useState<number>(0)


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
    


    let contributeHandler = function(e:any){
        e.preventDefault()
        setErrorMessage("internal server error")
        setErrCounter(prev => prev + 1)
    }

    let chamaContribute = function(e:any){
        e.preventDefault()
        let contribution = String(e.target.value)
        setChamaContribution(contribution)
    }

    let amountHandler = function(e:any){
        e.preventDefault()
    }

    return(
        <div className="w-full h-screen flex flex-col justify-center" >
            {notification}
            <h1 className="mt-12 mx-auto text-2xl font-bold mb-8 text-blue-600" >{chamaName}</h1>
            <h1 className="text-xl font-bold text-white mb-4 text-center">make your contribution</h1>
            <button className="w-4/6 sm:w-2/3 px-6 py-4 md:w-1/2 h-24 rounded-lg border-2 border-blue-600 text-blue-600 mx-auto font-bold text-3xl mb-4" onClick={amountHandler}>+{poolAmount}</button>  
            <button className="px-6 py-4 w-4/6 sm:w-2/3 md:w-1/2 rounded-lg bg-blue-600 mx-auto font-bold" onClick={contributeHandler}>contribute</button>  
        </div>
    )
}