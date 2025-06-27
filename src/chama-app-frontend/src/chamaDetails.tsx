import { act, Dispatch, SetStateAction, useEffect, useState } from "react"
import { FaArrowAltCircleRight, FaCalendarCheck, FaChargingStation, FaChartLine, FaCircle, FaCoins, FaCommentDots, FaDollarSign, FaInfoCircle, FaPen, FaPlus, FaRegWindowClose, FaShare, FaUser } from "react-icons/fa"
import { ChamaChat } from "./chamaChat"
import clsx from "clsx"
import { EmptyAlert } from "./notifications"
import { AuthClient } from '@dfinity/auth-client';
import { createActor } from '../../declarations/chama-app-backend';
import { canisterId } from '../../declarations/chama-app-backend/index';
import { ChamaMember, Create } from "./join"
import { Landing } from "./landing"


const identityProvider = 'https://identity.ic0.ap'



export type DateInfo = {
    year:string,
    month:string,
    day:string,
    hour:string,
    minute: string,
    second:string
}

export type ReceiverInfo = {
    //Principal
    principal: string,
    expectedAmount:number,
    dueDate:string,
    status:string
}

export type ContributionResult = {
    status:string,
    contributionAmount: number,
    //optional Principal
    receiver: string | undefined ,
    nextPayoutDate:string,
    transactionId:string
}

export type RoundStatus = {
    currentRound: any,
    totalContributions: any,
    expectedContributions:any,
    roundStartDate:string,
    daysRemaining:number
}

export type Contributor = {
    userName:string,
    amount:number,
    currency:string,
    time:string,
    roundIndividualContribution:number
}

export function valuesFormatter({amount}:{amount:string}){
    let actualValue:number = Number(amount)
    let finalAmount:string = amount

    if((actualValue / 1000) >= 1){
        //toFixed returns a string dont be surprised
        finalAmount =  `${Number(actualValue/1000).toFixed(2)}k`                
    }
    if((actualValue / 1000000) >= 1){
        //toFixed returns a string dont be surprised
        finalAmount =  `${Number(actualValue/1000000).toFixed(2)}m`                
    }
    if((actualValue / 1000000000) >= 1){
        //toFixed returns a string dont be surprised
        finalAmount =  `${Number(actualValue/1000000000).toFixed(2)}b`                
    }
    if((actualValue / 1000000000000) >= 1){
        //toFixed returns a string dont be surprised
        finalAmount =  `${Number(actualValue/1000000000000).toFixed(2)}t`                
    }
    if((actualValue / 1000000000000000) >= 1){
        //toFixed returns a string dont be surprised
        finalAmount =  `${Number(actualValue/1000000000000000).toFixed(2)}q`                
    }
    if((actualValue / 1000000000000000000) >= 1){
        //toFixed returns a string dont be surprised
        finalAmount =  `${Number(actualValue/1000000000000000000).toFixed(2)}q`                
    }
    return finalAmount
}


// in the roundStatus what exactly is the daysRemaining, and what is the round start date, I know the types but I need to understand what you mean by that.
// what are the days remaining in the round status
export function ChamaDetails({timeDifference,currency="USD",loanLimit=5000000000,setViewState,userName,chamaName,receiver,chamaMembers,daysRemaining,totalContributions,contributionAmount,nextPayoutDate}:{timeDifference:any,currency:string,loanLimit:number,setViewState:Dispatch<SetStateAction<JSX.Element>>,userName:string,daysRemaining:number,totalContributions:number,nextPayoutDate:string,receiver:string,chamaName:string,chamaMembers:Array<any>,contributionAmount:number}){
    const [totalMembers,setTotalMembers] = useState(0)
    const [customerDueDate,setCustomerDueDate] = useState<string>("")
    const [status,setStatus] = useState(false)
    const [expectedAmount,setexpectedAmount] = useState<number>(1000)
    const [dueDate,setDueDate] = useState<string>("29/6/25")
    const [editMode,setEditMode] = useState<boolean>(false)
    const [userNameState,setUserNameState] = useState<string>("")
    const [assistantState,setAssistantState] = useState<JSX.Element>(<></>)
    const [logout,setLogout] = useState<JSX.Element>(<></>)
    const [percentageContribution,setPercentageContribution] = useState(0)
    const [percentageContributors,setPercentageContributors] = useState(0)
    //Wallet states
    const [walletConnected,setWalletConnected] = useState(false)
    const [walletBalance,setWalletBalance] = useState(0.00)
    //Identity states
    const [actor,setActor] = useState<any>(null)
    const [authClient,setAuthClient] = useState<any>(null)
    const [authenticated,setAuthenticated] = useState<boolean>(false)
    const [principal,setPrincipal] = useState<string>("signin")
    
    useEffect(function(){
        setDueDate(nextPayoutDate)
    },[nextPayoutDate])

    useEffect(function(){
        async  function authClientInitialization(){
            const authClient = await AuthClient.create();
            setAuthClient(authClient)
        }

        authClientInitialization()

    },[])

    
    useEffect(function(){
        setTotalMembers(chamaMembers.length)
    },[chamaMembers])

    useEffect(function(){
        setUserNameState(userName)
    },[])

    let assistantHandler = function(e:any){
        e.preventDefault()
        setAssistantState(<ChamaChat schat={setAssistantState} />)
    }

    let editHandler = function(e:any){
        e.preventDefault()
        //certificate 
        setEditMode(true)
    }

    let editChange = function(e:any){
        e.preventDefault()
        setUserNameState(e.target.value)
    }

    let submitHandler = function(e:any){
        e.preventDefault()
        setEditMode(false)
    }

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

        setActor(actor)
        setAuthClient(authClient)
        setPrincipal(tempPrincipal)
        setUserNameState(tempPrincipal)
    };

    const identityLoginHandler = async (e:any) => {
        await authClient.login({
        identityProvider,
        onSuccess: updateActor
        });
    };

    const identityLogoutHandler = async (e:any) => {
        await authClient.logout();
        updateActor();
    };


    let loginHandler = function(e:any){
        e.preventDefault()
        identityLoginHandler(e)
    }

    let LogoutHandler  = function(e:any){
        setLogout(<Logout setViewState={setViewState} LogoutProp={identityLogoutHandler} loggedIn={authenticated} slogout={setLogout} />)
    }

    let newRotateHandler = function(e:any){
        e.preventDefault()
        setViewState(<Create setViewState={setViewState}/>)
    }


    return(
        <div className="w-full min-h-screen bg-black flex flex-col gap-4 select-none pb-12">
            <div className="w-full  h-24 flex justify-between items-center bg-black z-20 px-8 sticky top-0">
                <div className="w-auto flex items-center gap-8">
                    <h1 className="text-2xl  font-bold ml-4 text-blue-600 flex gap-2 line-clamp-1 "><FaCoins className="text-2xl text-blue-600"/><span>{chamaName}</span></h1>
                    <div onClick={newRotateHandler}  className="w-auto md:w-auto h-auto ml-8 flex flex-col mb-4 rounded-lg bg-white gap-3 p-4 md:px-8 py-4 border-2 border-blue-600">
                        <button className="w-auto text-xl font-bold space-x-1 text-center flex items-center gap-4  text-blue-600 " ><FaPlus className="text-blue-600 text-2xl"/><span className="hidden md:flex ">new rotatechain</span>
                        </button>
                    </div>

                </div>
                <div className="w-auto h-auto">
                    <div className="w-auto flex gap-4 items-center">
                        <p className="w-fit h-fit px-4 py-2 flex items-center bg-blue-100 text-green-600 font-bold text-xl rounded-lg ">{walletConnected == true ? walletBalance : "connect wallet" }</p>
                        <h2  className="text-xl font-bold hidden md:block text-slate-600 line-clamp-1" >{userNameState}</h2>
                        <div className="w-auto h-auto flex relative flex-col gap-4">
                            <div onClick={LogoutHandler} className="w-10 h-10 md:w-10 md:h-10 rounded-full p-2 flex justify-center items-center bg-slate-800">
                                <FaUser className="text-xl text-blue-600"/>
                            </div>
                            {logout}
                        </div>
                    </div>
                </div>
            </div>
            <div className="w-[90%] h-auto mx-auto flex flex-row flex-wrap gap-4 md:gap-8">
                <div className="w-fit md:w-1/4 h-auto flex flex-col mb-4 rounded-lg bg-transparent gap-3 p-4 md:px-8 py-4 border-2 border-blue-600">
                    <button className="w-full text-xl font-bold space-x-1 text-center flex items-center gap-4 text-blue-600 " ><FaDollarSign className="text-blue-600 text-2xl"/><span className="hidden md:flex ">add contribution</span></button>
                </div>
                <div className="w-fit md:w-1/4 h-auto flex flex-col mb-4 rounded-lg bg-transparent gap-3 p-4 md:px-8 py-4 border-2 border-blue-600">
                    {/*
                    {editMode == false ? <button onClick={editHandler}  className="w-full text-xl font-bold space-x-1 text-pink-600 text-center flex items-center gap-4" ><FaShare className="text-pink-600 text-2xl"/><span className="hidden md:flex ">share link</span></button> : <form onSubmit={submitHandler}><input value={userNameState} type="text" placeholder="new username" onChange={editChange} className="w-full text-xl font-bold space-x-1 text-green-600 text-center flex items-center gap-4"/></form> }
                    
                    */}
                    <button   className="w-full text-xl font-bold space-x-1 text-pink-600 text-center flex items-center gap-4" ><FaChargingStation className="text-pink-600 text-2xl"/><span className="hidden md:flex ">request loan</span></button>
                </div>
                {assistantState}
                <div className="w-fit  md:w-1/4 h-auto flex flex-col mb-4 rounded-lg bg-transparent gap-3 p-4 md:px-8 py-4 border-2 border-blue-600">
                    <button onClick={assistantHandler} className="w-full text-xl font-bold space-x-1 text-green-600 text-center flex items-center gap-4" > <FaCommentDots className="text-green-600 text-2xl"/><span className="hidden md:flex ">ask ai assistant</span> </button>
                </div>
            </div>
            <button onClick={assistantHandler} className="w-12 h-12 rounded-full md:hidden fixed flex justify-center items-center z-20 bottom-4 bg-slate-600 p-2 right-2">
                <FaCommentDots className="text-blue-600 text-4xl"/>
            </button>
            <div className="w-full h-auto flex flex-col gap-4 items-center">
                <div className="w-full h-auto flex wrap gap-4 justify-around">
                    <div className="w-1/2 md:w-1/4 h-auto bg-blue-100 rounded-lg  text-blue-600 px-2 py-4 sm:px-3 sm:py-6 md:px-8 md:py-6 flex gap-3 justify-center items-center">
                        {/*use a live currency converter  */}
                        <span className="text-blue-600 font-bold" >total contributions</span>
                        <span className="p-2 rounded-lg text-xl md:text-2xl bg-white text-green-600 font-bold"><span className="text-sm text-slate-600 mr-1" >USD</span>{valuesFormatter({amount:String(totalContributions)})}</span>
                    </div>
                    <div className="w-1/3 hidden md:w-1/4 h-auto bg-blue-100 rounded-lg  text-blue-600 px-2 py-4 sm:px-3 sm:py-6 md:px-8 md:py-6 md:flex gap-3 justify-center items-center">
                        <span className="text-blue-600 font-bold" >total members</span>
                        <span className="p-2 rounded-lg text-xl md:text-2xl bg-white text-blue-600 font-bold">{totalMembers}</span>
                    </div>
                    <div className="w-1/3 md:w-1/4 h-auto bg-blue-100 rounded-lg  text-blue-600 px-2 py-4 sm:px-3 sm:py-6 md:px-8 md:py-6 flex gap-3 justify-center items-center">
                        <span className="text-blue-600 font-bold" >loan limit</span>
                        <span className="p-2 rounded-lg text-xl md:text-2xl bg-white text-pink-600 font-bold flex items-end gap-2"><span className="text-sm text-black" >{currency}</span>{valuesFormatter({amount:String(loanLimit)})}</span>
                    </div>
                </div>
                <div className="w-full px-12 h-3/4  flex gap-12 justify-evenly md:justify-between items-center flex-wrap">
                    <div className="w-full md:w-1/2 justify-self-start h-auto flex flex-col rounded-lg p-4 md:px-8 bg-slate-400 ">
                        <h1 className="text-white font-bold text-xl mb-4 flex items-center gap-2" > <FaUser className="text-green-600 text-xl" /> my contribution status</h1>
                        <div className="w-full h-auto flex flex-col mb-4 rounded-lg bg-blue-100 gap-3 p-4 md:px-8 py-4 border-l-4 border-blue-600">
                            <p className="w-full text-xl font-bold space-x-1 text-black flex gap-2 items-center" ><FaInfoCircle/>expected amount</p>
                            <p className="w-full text-xl font-bold text-blue-600"><span className="text-sm text-slate-600 mr-1" >USD</span>{valuesFormatter({amount:String(contributionAmount)})}</p>
                        </div>
                        <div className="w-full h-auto flex flex-col mb-4 rounded-lg bg-blue-100 gap-3 p-4 md:px-8 py-4 border-l-4 border-blue-600">
                            <p className="w-full text-xl font-bold space-x-1 text-pink-600 flex gap-2 items-center" ><FaCalendarCheck/>due date</p>
                            <p className="w-full text-xl font-bold text-black">{dueDate}</p>
                        </div>
                        <div className="w-full h-auto flex flex-col mb-4 rounded-lg bg-blue-100 gap-3 p-4 md:px-8 py-4 border-l-4 border-blue-600">
                            <p className="w-full text-xl font-bold space-x-1 text-green-600 flex gap-2 items-center" ><FaCircle className={clsx("",{"text-green-600":status == true,"text-black":status == false})} />status</p>
                            <p className="w-full text-xl font-bold text-black">{status == true ? "active" : "inactive"}</p>
                        </div>
                    </div>
                    <div className="w-2/3 md:w-1/3 relative md:sticky top-0 h-auto rounded-lg bg-blue-100 sss">
                        <RoundDetails payout={totalContributions} currentReceiver={userName} activeContributors={chamaMembers.length} currency={currency} dueDate={nextPayoutDate} receiversRemaining={1} />
                    </div>
                </div>
            </div>
            <ContributionStats currency={currency} contribution={contributionAmount} contributors={chamaMembers} />
        </div>
    )
}

export function Logout({setViewState,LogoutProp,slogout,loggedIn}:{setViewState:Dispatch<SetStateAction<JSX.Element>>,LogoutProp:(e:any) => void,slogout:Dispatch<SetStateAction<JSX.Element>>,loggedIn:boolean}){

    let logoutHandler = function(e:any){
        e.preventDefault()
        LogoutProp(e)
        slogout(<></>)
        setViewState(<Landing/>)
    }

    let clearHandler = function(e:any){
        slogout(<></>)
    }

    return(
        <div  className="w-auto h-auto  flex z-20 flex-col absolute top-12 right-1 gap-3 px-3 py-3 bg-slate-600 rounded-lg">
            <FaRegWindowClose onClick={clearHandler} className="text-red-600 text-2xl relative self-end" />
            <h3 className="flex gap-2 items-center font-bold cursor-pointer" onClick={logoutHandler}><FaArrowAltCircleRight className={clsx("text-xl",{"text-red-600":loggedIn == false,"text-blue-600":loggedIn == true})}/>{"logout"} </h3>
        </div>
    )
}

export function RoundDetails({dueDate="22/7/2025",receiversRemaining=100,currentReceiver="Rogetz",payout=20000,currency="BTC",totalParticipants=2000,activeContributors=1600,roundNo=1,countDown="20:22:36:24",percentageContributors="80"}:{receiversRemaining ?: number,dueDate ?:string,payout ?:number,currency ?:string,currentReceiver ?:string,totalParticipants ?:number,activeContributors ?:number,percentageContributors ?:string,roundNo ?:number,countDown ?:string}){
    const [countDownState,setCountDownState] = useState(<></>)
    const [percentageContributorState,setPercentageContributorState] = useState("")
    const [secondsLeft,setSecondsLeft] = useState(0)
    const [minutesLeft,setMinutesLeft] = useState(0)
    const [hoursLeft,setHoursLeft] = useState(0)
    const [daysLeft,setDaysLeft] = useState(0)

    useEffect(function(){
        setPercentageContributorState(`${percentageContributors}%`)
    },[percentageContributors])

    useEffect(function(){

        let days = countDown.split(":")[3]
        let hours = countDown.split(":")[2]
        let minutes = countDown.split(":")[1]
        let seconds = countDown.split(":")[0]

        setDaysLeft(Number(days))
        setHoursLeft(Number(hours))
        setMinutesLeft(Number(minutes))
        setSecondsLeft(Number(seconds))


        let secondTimer = window?.setInterval(function(){
            if(secondsLeft == 0){
                
            }
            else{
                setSecondsLeft(prev => prev - 1)
            }
        },1000)
        let minuteTimer = window?.setInterval(function(){
            if(minutesLeft == 0){
                
            }
            else{
                setMinutesLeft(prev => prev - 1)
                setSecondsLeft(60)
            }
        },1000 * 60)
        
        let hourTimer = window?.setInterval(function(){
            if(hoursLeft == 0){
                
            }
            else{
                setHoursLeft(prev => prev - 1)
                setMinutesLeft(60)
            }
        },1000 * 60 * 60)

        let dayTimer = window?.setInterval(function(){
            if(daysLeft == 0){
                
            }
            else{
                setDaysLeft(prev => prev - 1)
                setHoursLeft(24)
            }
        },1000 * 60 * 60 * 24)

        setCountDownState(<span>{days} days {hours} hrs {minutes} min {seconds} sec</span>)
    
        return () => {
            clearInterval(secondTimer)
            clearInterval(minuteTimer)
            clearInterval(hourTimer)
            clearInterval(dayTimer)
        }

    },[countDown])

    return(
        <div className="w-full h-full flex flex-col gap-3 px-4 py-4" >
            <h1 className="text-xl text-blue-600 font-bold flex gap-2 items-center mt-2"><FaChartLine className="text-pink-600 text-xl " />Round Info</h1>
            <div className="flex justify-between items-center border-b-2 border-blue-600">
                <h1 className="w-fit h-fit flex flex-col"><span className="text-sm text-slate-700">round no</span> <span className="font-bold" >{roundNo}</span>   </h1>
                <div className="w-fit h-fit flex flex-col justify-start items-center ">
                    {/*duration before the current receiver receives his chama contribution for the round in days, hours and seconds*/}
                    <div className="w-fit h-fit text-sm text-slate-700">
                        countdown
                    </div>
                    <p className="w-auto h-fit font-bold text-blue-600 flex gap-2" >
                        {countDownState}
                    </p>
                </div>
            </div>
            <div className="flex justify-between items-center border-b-2 border-blue-600">
                <div className="w-full flex flex-col gap-2" >
                    <span className="text-sm text-slate-700">current receiver</span>
                    <span className="font-bold" >{currentReceiver}</span>
                </div>
                <div className="w-full h-auto flex flex-col gap-2" >
                    <div className="text-sm text-slate-700">payout</div>
                    {/*amount the receiver will get */}
                    <div className="w-auto flex gap-2 font-bold" ><span>{currency}</span><span>{payout}</span></div>
                </div>
            </div>
            <div className="flex justify-between items-center border-b-2 border-blue-600">
                <div className="flex flex-col gap-2">
                    <div className="text-sm text-slate-700" >total participants</div>
                    <div className="font-bold" >{activeContributors}</div>
                </div>
                <div className="flex flex-col gap-2">
                    <div className="text-sm text-slate-700" >active contributors</div>
                    <div className="font-bold">{activeContributors}</div>
                </div>
            </div>
            <div className="flex flex-col gap-2 w-full">
                <div className="text-sm text-slate-700" >contributions rate</div>
                <div className={`w-full h-3 rounded-2xl bg-white`} >
                    <div style={{width:percentageContributorState}} className={` h-full rounded-2xl bg-blue-600 `} >

                    </div>
                </div>
            </div>
            <div className="flex flex-col bg-blue-100 px-6 py-2 rounded-lg">
                <div className="text-sm text-slate-700">due date</div>
                <div className="font-bold" >{dueDate}</div>
            </div>
            <div className="flex flex-col bg-blue-100 px-6 py-2 rounded-lg">
                <div className="text-sm text-slate-700">receivers remaining</div>
                <div className="font-bold" >{receiversRemaining}</div>
            </div>
        </div>
    )
}

let fakeContributors:Array<Contributor> = [
    {
        amount:5000,
        currency:"USD",
        roundIndividualContribution:10000,
        time:"22:00 22/7/25",
        userName:"Tobby"
    },
        {
        amount:10000,
        currency:"USD",
        roundIndividualContribution:10000,
        time:"08:00 23/7/25",
        userName:"Shem"
    },
    {
        amount:7000,
        currency:"USD",
        roundIndividualContribution:10000,
        time:"03:00 21/7/25",
        userName:"Stacey"
    },
    {
        amount:4000,
        currency:"USD",
        roundIndividualContribution:10000,
        time:"09:00 20/7/25",
        userName:"Tevin"
    },
    {
        amount:8000,
        currency:"USD",
        roundIndividualContribution:10000,
        time:"20:00 22/7/25",
        userName:"Jane"
    }
]

export function ContributionStats({currency,contributors,contribution}:{currency:string,contribution:number,contributors ?:Array<ChamaMember>}){
    const [contributorsViewState,setContributorsViewState] = useState<Array<JSX.Element>>([])

    useEffect(function(){

        if(contributors && contributors.length > 0){
            setContributorsViewState(
                contributors.map(function(contributor,index){
                    let contRate = `${(Number(contributor.contribution) / Number(contribution) * 100)}%`
                    
                    return(
                        <div className="w-full h-8 border-b-2 border-blue-600 grid grid-cols-4 justify-center gap-4 bg-transparent">
                            <div>{contributor.userName}</div>
                            <div className="flex gap-2" ><span>{currency}</span><span>{contributor.contribution}</span></div>
                            <div className="w-full h-full flex items-center">
                                <div className="w-full h-4 my-a bg-white rounded-xl overflow-hidden">
                                    <div style={{width:contRate}} className="h-full bg-pink-600"></div>
                                </div>
                            </div>
                            <div>{contributor.date}</div>                    
                        </div>
                    )
                })
            ) 
        }else{
            setContributorsViewState([<EmptyAlert message="no contributions made yet for this current round be the first one"  />]) 
        }
    },[contributors])

    return(
        <div className="relative ml-8">
            <div className="w-full md:w-[60%] h-auto rounded-lg px-4 py-4 bg-blue-100" >
                <div className="w-full h-auto flex flex-col gap-4  sticky top-0 z-20 bg-transparent backdrop-blur-xl">

                    <h1 className="font-bold text-blue-600">round contribution stats</h1>
                    <div className="w-full h-8 border-b-2 border-blue-600 grid grid-cols-4 gap-4 font-bold text-blue-600 text-xl">
                        <div>userName</div>
                        <div>amount</div>
                        <div>target rate</div>
                        <div>date</div>
                    </div>
                </div>
                <div className="w-full  h-auto ">
                    {contributorsViewState}
                </div>
            </div>
        </div>
    )
}

