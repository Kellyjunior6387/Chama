import { Dispatch, SetStateAction, useEffect, useState } from "react"
import { FaAirbnb, FaCaretDown, FaCaretRight, FaChalkboardTeacher, FaCheckCircle, FaCopyright, FaGlasses, FaRegBell, FaShippingFast, FaTelegramPlane, FaTruckLoading, FaUserFriends } from "react-icons/fa"
import { Create, InternetIdentityLogin, Join } from "./join"
import "../ui/globals.css"
import "./index.scss"
import clsx from 'clsx';
import { Notification } from './notifications';




export function Landing(){
    const [viewState,setViewState] = useState(<></>)
    const [authenticated,setAuthenticated] = useState(false)
    
    useEffect(function(){
        if(authenticated){
            setViewState(<Join setViewState={setViewState} />)
        }else{
            setViewState(<Welcome setViewState={setViewState}/>)
        }
    },[authenticated])

    return(
        <div className="w-full min-h-screen">
            {viewState}
        </div>
    )
}

type ActionType = {
    actionName:string,
    detailIcon:JSX.Element,
    details:string,
    title: string
}

type FaqType = {
    faqTitle: string,
    faqMessage:string
}

let detailsArray:Array<ActionType> = [
    {
        title:"transparency",
        actionName:"see more",
        detailIcon:<FaCheckCircle className='text-blue-600'/>,
        details:"roundchain is a blockchain-powered investment group designed to bring trust, transparency and efficiency to how we pool and grow our finances"
    },
    {
        title:"decentralization",
        actionName:"see more",
        detailIcon:<FaTruckLoading className='text-blue-600'/>,
        details:"Built on decentralized technology, roundchain ensures that every contribution, withdrawal and transaction is secure, traceable and tamper-proof."
    },
    {
        title:"funds security",
        actionName:"see more",
        detailIcon:<FaRegBell className='text-blue-600'/>,
        details:"your funds are securely stored in our chainlinks ensuring none is lost. We integrate all the blockchain servers in the storage process ensuring its proofed from any inconsistency"
    },


]

let faqsArray:Array<FaqType> = [
    {
        faqTitle:"How to get started ?",
        faqMessage:"You can either create a rotate group or join a rotate group. Creating a group is quite simple, click on the create group fill in the create form and submit .For joining, RotateChain admins send you an invite to join their rotate groups. Once you've joined the rotate groups you can send an invite to others to join the chama group"
    },
    {
        faqTitle:"How do I make contributions ?",
        faqMessage:"depending on the amount set by the group owner, each member is expected to pay his or her contribution based on the amount contribution set set by the owner. The time intervals to send or make your contribution is also set by the owner, it can be a daily, weekly,monthly or annual"
    },
    {
        faqTitle:"What currency is suppported ?",
        faqMessage:"All currencies are supported. However the currency to be used by each group is set by the group owner/creator"
    },
    {
        faqTitle:"How do I get paid ?",
        faqMessage:"Your payment is made instantly on your address"
    },
    {
        faqTitle:"How much do I pay in my chama group ?",
        faqMessage:"You pay the amount stipulated by the chama group owner or admin. The value may vary depending on the amount stipulated by the chama owner or creator. Currency used is also determined by the group owner"
    },
    {
        faqTitle:"Can I be frauded ?",
        faqMessage:"NO for as long as you keep your passwords safe, your money is in safe hands and is held by no single entity"
    }
]


export function Welcome({setViewState}:{setViewState:Dispatch<SetStateAction<JSX.Element>>}){
    const [notificationState,setnotificationState] = useState<JSX.Element>(<></>)
    const [counterState,setcounterState] = useState(0)

    let joinHandler = function(e:any){
        e.preventDefault()
        setViewState(<InternetIdentityLogin NextView={<Join setViewState={setViewState} />} setViewState={setViewState} />)
    }

    let createHandler = function(e:any){
        e.preventDefault()
        setViewState(<InternetIdentityLogin NextView={<Create setViewState={setViewState} />} setViewState={setViewState} />)
    } 

    let subscribeHandler = function(e:any){
        setcounterState(prev => prev + 1)
        setnotificationState(<Notification counter={counterState} message='thankyou for subscribing to our news letter' />)
    }
    return(
        <div className="w-full h-screen px-4 sm:px-8 md:px-12 relative select-none">
            {notificationState}
            <div className="w-full md:w-full h-4/5 relative mx-auto mt-24 flex flex-col gap-4">
                <h1 className='relative w-full h-auto text-left text-2xl font-bold text-blue-600 flex items-center justify-start gap-3'><FaUserFriends  className='text-blue-600 text-4xl'/> <span><span className='text-blue-600' >Rotate</span><span className='text-pink-600' >Chain</span></span>  </h1>
                <h1 className="w-full h-auto font-bold text-7xl mb-4">Invest In your Investment</h1>
                <p className="text-sm text-slate-600 font-bold">Get individual loans of more than <span>200%</span> your group contribution</p>
                <div className='h-8 w-full md:w-1/2 overflow-hidden'>
                    <div className="w-auto h-auto overflow-hidden px-6 py-2 animate-margin">
                        <h2 className="w-5/6 h-8 font-bold flex gap-2 items-center text-orange-600 text-2xl">Fast <FaShippingFast className="text-pink-600 text-2xl" /> </h2>
                        <h2 className="w-5/6 h-8 font-bold flex gap-2 items-center text-blue-600 text-2xl">Transparent <FaGlasses className='text-2xl'/> </h2>
                        <h2 className="w-5/6 h-8 font-bold flex gap-2 items-center text-indigo-600 text-2xl">Smart <FaAirbnb className='text-2xl'/></h2>
                        <h2 className="w-5/6 h-8 font-bold flex gap-2 items-center text-violet-600 text-2xl">Insured<FaCheckCircle className='text-2xl' /></h2>
                    </div>
                </div>
                <h3 className="text-xl text-pink-600" >Join rotateChain Today and experience investment the smart way</h3>
                <div className='w-full md:w-1/3 h-auto flex gap-2 justify-between flex-wrap' >
                    <button className="w-full md:w-1/3 h-auto px-7 py-3 text-white bg-blue-600 font-bold rounded-lg mt-4 mb-4" onClick={joinHandler} >join</button>
                    <button className="w-full md:w-1/3 h-auto px-7 py-3 text-white bg-pink-600 font-bold rounded-lg mt-4 mb-4 mx-auto" onClick={createHandler} >create</button>
                </div>
            </div>
            <div className="w-full h-auto relative flex justify-end">
                <img src="./dashboard_capture.PNG" className="w-2/3 md:w-3/5  object-fit object-center   mt-8 h-[28rem] md:mt-[-20rem] overflow-hidden self-end mr-1 rounded-lg shadow-md shadow-blue-600 relative" />
            </div>
            <div className='w-full h-auto flex flex-col items-center gap-8  my-8 mt-24 '>
                <h1 className='font-bold text-xl mb-8' >What we offer ?</h1>
                <div className='w-full h-auto flex gap-8 flex-wrap mx-auto justify-center'>
                    {detailsArray.map((info,index) => {
                    return <InfoCard title={info.title} actionName={info.actionName} detailIcon={info.detailIcon} details={info.details} key={index}  /> 
                    } )}
                    
                </div>
            </div>
            <div className='w-full h-auto flex flex-col items-center gap-8 my-8 mt-24 mx-auto' >
                <h1 className='font-bold text-xl mb-8'>FAQS</h1>
                <div className='w-full sm:w-3/4 shadow-sm px-6 py-4 border-blue-600 md:w-1/2 flex flex-col gap-3 mt-4 '>
                    {faqsArray.map((faq,index) => {
                        return <FaqButton faqMessage={faq.faqMessage} faqTitle={faq.faqTitle} key={index}  />
                    } )}
                    
                </div>
            </div>
            <div className='w-full h-auto flex flex-col mt-24 items-center gap-4'>
                <h1 className='text-xl font-bold'>subscribe to our news letter</h1>
                <form onSubmit={subscribeHandler} className='w-3/4 md:w-1/2 h-12 mx-auto flex justify-center rounded-lg overflow-hidden'>
                    <input className='w-4/5 border-blue-600 px-4  text-white bg-slate-600' type='text' placeholder='enter your email here' />
                    <button type='submit' className='w-fit h-full bg-blue-200 flex items-center justify-center px-3'> 
                        <FaTelegramPlane className='text-2xl text-blue-600'/>
                    </button>
                </form>
            </div>
            <p className='text-xl text-blue-600 font-bold text-center mt-24 hidden'>OGETA</p>
            <div className='w-full h-auto relative mt-8 mb-4 md:mb-12 flex items-center justify-center gap-2'>copyright <FaCopyright className='text-blue-600 text-xl' /> 2025</div>
        </div>
    )
}

export function InfoCard({title,actionName,detailIcon,details}:{title:string,actionName:string,detailIcon:JSX.Element,details:string}){
    return(
        <div className='w-full md:w-1/4 relative h-auto rounded-xl px-6 py-4 bg-white border-1 shadow-inner shadow-blue-600 border-blue-600 '>
            <div className='absolute top-4 left-8 w-auto h-auto flex justify-start gap-4 items-center text-2xl'>
                {detailIcon}
                <h1 className='text-blue-600 font-bold text-xl'>{title}</h1>
            </div>
            <div className='w-full h-fit py-4 line-clamp-4 flex items-center justify-center mt-12 ' >
                <p className='w-full flex justify-center items-center text-black' >{details}</p>
            </div>
            <button className='w-full h-2 my-3 mx-auto bg-white text-white text-center rounded-xl flex justify-center items-center ' >
                <div className="animate-progressLoad h-full bg-blue-600 rounded-xl ">

                </div>
            </button>
        </div>
    )
} 

export function FaqButton({faqTitle,faqMessage}:{faqTitle:string,faqMessage:string}){
    const [toggleState,setToggleState] = useState(false)

    let toggleHandler = function(){
        if(toggleState == false){
            setToggleState(true)
        }else[
            setToggleState(false)
        ]
    }

    return(
        <div className='w-full h-auto border-2 mx-auto border-blue-600 rounded-lg text-white flex flex-col px-4'>
            <h1 onClick={toggleHandler} className='w-full text-center text-xl font-bold py-3 text-blue-600 h-auto flex items-center justify-center' >{faqTitle}<FaCaretRight className={clsx("text-blue-600",{"hidden":toggleState == true,"flex":toggleState == false})} /><FaCaretDown className={clsx("text-blue-600",{"flex":toggleState == true,"hidden":toggleState == false})} /></h1>
            <div className={clsx("text-black px-4 flex py-3 justify-center text-center",{"hidden":toggleState == false, "flex":toggleState == true})}>
                {faqMessage}
            </div>
        </div>
    )
}