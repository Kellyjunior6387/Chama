import { Dispatch, SetStateAction, useEffect, useState } from "react"
import { Error, Notification } from "./notifications"
import { ChamaDetails } from "./chamaDetails"
import { useAppDispatch } from "./states/hooks"
import {DateTime} from "luxon"
import { AuthClient } from '@dfinity/auth-client';
import { addActor, addAuthClient } from "./states/newReducer"
import { canisterId, createActor } from "../../declarations/chama-app-backend"

//For mainnet
const identityProvider = 'https://identity.ic0.app'
//locally
//const identityProvider = 'http://rdmx6-jaaaa-aaaaa-aaadq-cai.localhost:4945'

export type ChamaMember = {
    userName:string,
    id:string,
    contribution:string,
    date:string
}

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
        let userName = e.target.userName.value
        let inviteLink = e.target.inviteLink.value

        let now = DateTime.now()
        let year = now.year
        let month = now.month
        let day = now.day
        let hour = now.hour
        let minute = now.minute
        let second = now.second
        let dateCreated = `${day}/${month}/${year} ${hour}:${minute}:${second}`
        let paymentTime = `${hour}:${minute}:${second} ${day}/${month}/${year}`
        let scheduledPayoutDate = now.plus({days:30})
        let scheduledPayoutDatYear = scheduledPayoutDate.year
        let scheduledPayoutDateMonth = scheduledPayoutDate.month
        let scheduledPayoutDateDay = scheduledPayoutDate.day
        let scheduledPayoutDateHour = scheduledPayoutDate.hour
        let scheduledPayoutDateMinute = scheduledPayoutDate.minute
        let scheduledPayoutDateSecond = scheduledPayoutDate.second
        let ScheduledPayoutDateFormatted = `${scheduledPayoutDateDay}/${scheduledPayoutDateMonth}/${scheduledPayoutDatYear} ${scheduledPayoutDateHour}:${scheduledPayoutDateMinute}:${scheduledPayoutDateSecond}`
        //ISO's
        let nowISO = now.toISO()
        let scheduledISO = scheduledPayoutDate.toISO()

        let start = DateTime.fromISO(nowISO) 
        let end = DateTime.fromISO(scheduledISO)

        let timeDifference = end.diff(start,["years","months","days","hours","minutes","seconds"]).toObject()


        if(userName != "" && inviteLink != ""){
            setNotCounter(prev => prev + 1)
            setNotificationMessage("joined successfuly")
            setViewState(<ChamaDetails currency="USD" timeDifference={timeDifference} loanLimit={50000000} chamaMembers={[{userName:"Ronny",id:"sbjbsjbdsbdbv93884h4b48895b43jb",contribution:"5000",date:paymentTime},{userName:"Tony",id:"sbjbsjbsbndbv93884h4b48895b43jb",contribution:"5000",date:paymentTime},{userName:"Samson",id:"sbjbsjbdvbhbv93884h4b48895b43jb",contribution:"10000",date:paymentTime},{userName:"Shem",id:"sbjbsjbdvbhbv93884h4b48895b43jb",contribution:"6000",date:paymentTime},{userName:"Steven",id:"sbjbsjbdvbhbv93884h4b488dg5b43jb",contribution:"8000",date:paymentTime},]} chamaName="wachapakazi" contributionAmount={2000000} daysRemaining={Number(timeDifference.days)} nextPayoutDate={ScheduledPayoutDateFormatted} receiver="James" totalContributions={5000000} userName="James"   setViewState={setViewState}/>)
        }
        else{
            setErrCounter(prev => prev + 1)
            setErrorMessage("kindly fill in all the details")
        }

    }

    return(
        <div className="w-full h-screen flex flex-col justify-center select-none " >
            {notification}
            <h1 className="text-xl font-bold text-slate-600 mb-4 text-center">welcome to roundchain select a roundchain group to join</h1>
            <h1 className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg text-black font-bold text-xl mx-auto" >input your userName and invite link to continue</h1>
            <form onSubmit={joinHandler} className="w-full h-auto  ">
                <input className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-3" type="text" name="userName" placeholder="username" />
                <input className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-3" type="text" name="inviteLink" placeholder="invite link" />
                <button className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg bg-blue-600 mx-auto mt-3 text-white" type="submit">join</button>
            </form>
        </div>
    )
}

//to show the next view and set the redux state
export function InternetIdentityLogin({setViewState,NextView}:{NextView:JSX.Element,setViewState:Dispatch<SetStateAction<JSX.Element>>}){
    const [authenticated,setAuthenticated] = useState<boolean>(false)
    const [authClient,setAuthClient] = useState<any>(null)
    const reduxDispatch = useAppDispatch()

    useEffect(function(){
        //update redux authClient state authenticated state as well as the authClient
        
    },[authenticated])

    useEffect(function(){
        async  function authClientInitialization(){
            const authClient = await AuthClient.create();
            setAuthClient(authClient)
        }

        authClientInitialization()

    },[])


    const updateActor = async () => {
        const authClient = await AuthClient.create();
        const identity = authClient.getIdentity();
        const actor = createActor(canisterId, {
        agentOptions: {
            identity
        }
        });
        let tempPrincipal = identity.getPrincipal.toString()

        const isAuthenticated = await authClient.isAuthenticated();
        setAuthenticated(isAuthenticated)

        reduxDispatch(addActor(actor))
        reduxDispatch(addAuthClient(authClient))

        if(isAuthenticated == true){
            setViewState(NextView)
        }

    };

    const identityLoginHandler = async (e:any) => {
        await authClient.login({
        identityProvider,
        onSuccess: updateActor
        });
    };


    let loginHandler = function(e:any){
        e.preventDefault()
        //use the identityLogin after demo for projects submission
        setViewState(NextView)
    }

    return(
        <div className="w-full h-screen flex flex-col justify-center select-none " >
            <h1 className="text-xl font-bold text-slate-600 mb-4 text-center">welcome to roundchain Login with Internet Identity to continue</h1>
            <button onClick={identityLoginHandler}  className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg bg-blue-600 mx-auto mt-3 text-white" >Login with internet identity</button>
        </div>
    )
}


let tempCurrencies = ["USD","BTC","ETH","YEN","KSH","USH","TSH","SOL","WLC"]

export function Create({setViewState}:{setViewState:Dispatch<SetStateAction<JSX.Element>>}){
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

    let createHandler = function(e:any){
        e.preventDefault()
        let chamaName = e.target.groupName.value.toLowerCase()
        let userName = e.target.userName.value.toLowerCase()
        let amount = e.target.amount.value
        let currency = e.target.currency.value
        let membersLimit = e.target.membersLimit.value
        let loanLimit = Number(amount) * Number(membersLimit) * 2
        let roundInterval = e.target.roundInterval.value

        let now = DateTime.now()
        let year = now.year
        let month = now.month
        let day = now.day
        let hour = now.hour
        let minute = now.minute
        let second = now.second
        let dateCreated = `${day}/${month}/${year} ${hour}:${minute}:${second}`
        let paymentTime = `${hour}:${minute}:${second} ${day}/${month}/${year}`
        let scheduledPayoutDate = now.plus({days:roundInterval})
        let scheduledPayoutDatYear = scheduledPayoutDate.year
        let scheduledPayoutDateMonth = scheduledPayoutDate.month
        let scheduledPayoutDateDay = scheduledPayoutDate.day
        let scheduledPayoutDateHour = scheduledPayoutDate.hour
        let scheduledPayoutDateMinute = scheduledPayoutDate.minute
        let scheduledPayoutDateSecond = scheduledPayoutDate.second
        let ScheduledPayoutDateFormatted = `${scheduledPayoutDateDay}/${scheduledPayoutDateMonth}/${scheduledPayoutDatYear} ${scheduledPayoutDateHour}:${scheduledPayoutDateMinute}:${scheduledPayoutDateSecond}`
        //ISO's
        let nowISO = now.toISO()
        let scheduledISO = scheduledPayoutDate.toISO()

        let start = DateTime.fromISO(nowISO) 
        let end = DateTime.fromISO(scheduledISO)

        let timeDifference = scheduledPayoutDate.diff(now,["years","months","days","hours","minutes","seconds"]).toObject()

        if(((chamaName != "" && userName != "") && (currency != "" && membersLimit > 0)) && ((amount > 0 && loanLimit > 0) && roundInterval > 0) ){
            setNotCounter(prev => prev + 1)
            setNotificationMessage("created rotate group successfuly")
            setViewState(<ChamaDetails currency={currency} loanLimit={0.00} chamaMembers={[{userName:userName,contribution:"0",date:paymentTime,id:"sbjbsjbdvbhbv93884h4b48895b43jb"}]} chamaName={chamaName} contributionAmount={amount} daysRemaining={Number(timeDifference.days)} nextPayoutDate={ScheduledPayoutDateFormatted} receiver="dbjkndkfnksh4578djbn348934bb-23" totalContributions={0.00} userName={userName} timeDifference={timeDifference}   setViewState={setViewState}/>)
        }else{
            setErrCounter(prev => prev + 1)
            setErrorMessage("kindly fill in all the details")
        }
    }

    return(
        <div className="w-full min-h-screen flex flex-col justify-center select-none " >
            {notification}
            <h1 className="text-xl font-bold text-slate-600 mb-4 text-center">welcome to RotateChain create a name for your rotate group</h1>
            <h1 className="px-6 py-4 w-full text-center rounded-lg text-black font-bold text-xl mx-auto" >Fill in your group details to continue</h1>
            <form onSubmit={createHandler} className="w-full h-auto flex flex-col items-center gap-4">
                <div className="W-full h-auto flex flex-col gap-1 items-start">
                    <label className="text-xl font-bold" htmlFor="userName">userName</label>
                    <input name="userName" className="px-6 py-4 w-full rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-0" type="text" placeholder="e.g John/Jane" />
                </div>                
                <div className="W-full h-auto flex flex-col gap-1 items-start">
                    <label className="text-xl font-bold" htmlFor="">group name</label>
                    <input name="groupName" className="px-6 py-4 w-full rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-0" type="text" placeholder="e.g targeters/elites" />
                </div>
                <div className="W-full h-auto flex flex-col gap-1 items-start">
                    <label className="text-xl font-bold" htmlFor="">currency</label>
                    <select name="currency" className="px-6 py-4 w-full rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-0"  >
                        {tempCurrencies.map((currency,index) => {
                            return <option>{currency}</option>
                        })}
                    </select>
                </div>
                <div className="W-full h-auto flex flex-col gap-1 items-start">
                    <label className="text-xl font-bold" htmlFor="">max no of group members</label>
                    <input name="membersLimit" className="px-6 py-4 w-full rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-0" type="number" placeholder="e.g 50/100/1000" />
                </div>
                <div className="W-full h-auto flex flex-col gap-1 items-start">
                    <label className="text-xl font-bold" htmlFor="">individual contribution amount per round</label>
                    <input name="amount" className="px-6 py-4 w-full rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-0" type="number" placeholder="e.g 10000" />
                </div>
                <div className="W-full h-auto flex flex-col gap-1 items-start">
                    <label className="text-xl font-bold" htmlFor="">round intervals (days)</label>
                    <input name="roundInterval" className="px-6 py-4 w-full rounded-lg text-xl border-2 border-blue-600 bg-white text-black-600 mx-auto my-0" type="number" placeholder="e.g 30days,7days/day " />
                </div>

                <button type="submit" className="px-6 py-4 w-5/6 sm:w-2/3 md:w-1/2 rounded-lg bg-blue-600 mx-auto mt-3 text-white" >create</button>
            
            </form>
        </div>
    )
}


