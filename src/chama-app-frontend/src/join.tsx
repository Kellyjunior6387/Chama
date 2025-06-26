import { Dispatch, SetStateAction, useEffect, useState } from "react"
import { Error, Notification } from "./notifications"
import { ChamaDetails } from "./chamaDetails"


// join a chama
export function Join({setViewState}:{setViewState:Dispatch<SetStateAction<JSX.Element>>}){
    // use the chama type such as name and address
    const [chamas,setChamas] = useState<Array<string>>([])
    const [notification,setNotification] = useState<JSX.Element>(<></>)
    const [chamaSelected,setChamaSelected] = useState<string>("")
    const [errorMessage,setErrorMessage] = useState<string>("")
    const [notificationMessage,setNotificationMessage] = useState<string>("")
    const [notCounter,setNotCounter] = useState<number>(0)
    const [errCounter,setErrCounter] = useState<number>(0)
    const [authenticated,setAuthenticated] = useState(false)


    useEffect(function(){
        // chamabackend join logic updating chamas
    },[])



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



    let chamaChange = function(e:any){
        e.preventDefault()
        let chama = e.target.value.toLowerCase()
        setChamaSelected(chama)
    }

    let joinHandler = function(e:any){
        e.preventDefault()
        setNotificationMessage("joined successfuly")
        setNotCounter(prev => prev + 1)
        setViewState(<ChamaDetails currency="USD" tradeLimit={50000000000} chamaMembers={[{name:"Ronny Ogeta",id:"sbjbsjbdvbhbv93884h4b48895b43jb"},{name:"Tony Ojwang",id:"sbjbsjbdbjfhbv93884h4b48895b43jb"},{name:"Stephen Letoo",id:"sbjbsjbdvbhbv93884h4b48sbjdbnjk3jb"}]} chamaName="wachapakazi" contributionAmount={2000000} daysRemaining={10} nextPayoutDate="29/7/2025" receiver="dbjkndkfnksh4578djbn348934bb-23" totalContributions={5000000} userName="msanii"   setViewState={setViewState}/>)
    }

    return(
        <div className="w-full h-screen flex flex-col justify-center select-none " >
            {notification}
            <h1 className="text-xl font-bold text-white mb-4 text-center">welcome to Chama select a chama group to join</h1>
            <h1 className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg text-black text-xl mx-auto" >input your invite link to continue</h1>
            <input className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-3" type="text" placeholder="invite link" />
            <button className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg bg-blue-600 mx-auto mt-3 text-white" onClick={joinHandler}>join</button>
        </div>
    )
}