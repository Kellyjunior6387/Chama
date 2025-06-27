//for the notifications
import { useEffect,useState } from "react"
import clsx from "clsx"
import { FaInfoCircle } from "react-icons/fa"


export function Notification({message,counter}:{message:string,counter:number}){
    const [VisibilityState,setVisibilityState] = useState(false)


    useEffect(function(){
        setVisibilityState(true)
        setTimeout(function(){
            setVisibilityState(false)
        },3000)
    },[counter])

    return(<div className={clsx("fixed top-20 mx-auto border-green-600 bg-white z-20  flex-row items-center gap-4 rounded-lg border-2 px-7 py-4",{"hidden":VisibilityState == false,"visible flex":VisibilityState == true})}>
        <FaInfoCircle className="text-green-600 font-bold" />
        <h1 className="text-green-600 font-bold" >{message}</h1>
    </div>)
}

export function Error({message,counter}:{message:string,counter:number}){
    const [VisibilityState,setVisibilityState] = useState(false)


    useEffect(function(){
        setVisibilityState(true)
        setTimeout(function(){
            setVisibilityState(false)
        },3000)
    },[counter])

    return(<div className={clsx("fixed top-20 mx-auto border-red-600 bg-white z-20  flex-row items-center gap-4 rounded-lg border-2 px-7 py-4",{"hidden":VisibilityState == false,"visible flex":VisibilityState == true})}>
        <FaInfoCircle className="text-red-600 font-bold" />
        <h1 className="text-red-600 font-bold">{message}</h1>
    </div>)
}

export function EmptyAlert({message}:{message:string}){
    return(
        <div className="w-3/4 md:w-2/3 h-auto bg-white flex justify-start gap-2 md:gap-3 px-4 py-4" >
            <FaInfoCircle className="text-xl md:text-2xl text-blue-600" />
            <h1 className="bg-black">{message}</h1>
        </div>
    )
}