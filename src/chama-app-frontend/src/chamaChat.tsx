import { clsx } from "clsx"
import { DateTime } from "luxon"
import { Dispatch, SetStateAction, useEffect, useRef, useState } from "react"
import { FaInfoCircle, FaRegWindowClose, FaTelegramPlane } from "react-icons/fa"

export type Chat = {
    message:string,
    time:string,
    sender:boolean
}

let fakeChats:Array<Chat> = [
    {
        message:"hello there",
        sender:false,
        time:"22/6/2025 06:30"
    },
    {
        message:"hello I'm very fine how may I assist you today",
        sender:true,
        time:"22/6/2025 06:32"
    }

] 


export function ChamaChat({schat}:{schat:Dispatch<SetStateAction<JSX.Element>>}){
    const [chats,setChats] = useState<Array<Chat>>([])
    const [chat,setChat] = useState<JSX.Element>()
    const haRef = useRef<HTMLDivElement>(null)
    const [authenticated,setAuthenticated] = useState(false)

    //uncomment later
    useEffect(function(){
        setChats(fakeChats)
    },[])

    useEffect(function(){
        haRef.current?.scrollIntoView()
    },[chat])

    useEffect(function(){
        setChat(

            <div className="w-full h-4/5 overflow-auto relative flex flex-col items-center mt-4 mx-auto">
                {chats.map((chat,index) => {
                return <SingleChat message={chat.message} sender={chat.sender} time={chat.time} key={index} />
                })}
                <div ref={haRef}></div>
            </div>
        )
    },[chats])

    let cancelHandler = function(e:any){
        e.preventDefault()
        schat(<></>)
    }

    let submitHandler = function(e:any){
        e.preventDefault()
        let text = String(e.target.message.value)

        let now = DateTime.now()
        let year = now.year
        let month = now.month
        let day = now.day
        let hour = now.hour
        let minute = now.minute
        let second = now.second
        let dateCreated = `${day}/${month}/${year} ${hour}:${minute}`

        

        let newChat:Chat = {
            message:text,
            sender:false,
            time:dateCreated
        } 

        setChats(prev => [...prev,newChat])
        e.target.message.value = ""

        if(text.includes("hello")){

            let now = DateTime.now()
            let year = now.year
            let month = now.month
            let day = now.day
            let hour = now.hour
            let minute = now.minute
            let second = now.second
            let dateCreated = `${day}/${month}/${year} ${hour}:${minute}`
            

            let AiMockChat:Chat = {
                message:"Hello and welcome to round chain assistant, how may hi help you today",
                sender:true,
                time:dateCreated
            }
            
            if(window){
                window.setTimeout(function(){
                    setChats(prev => [...prev,AiMockChat])

                },2000)
            }

        }
        else{

            let now = DateTime.now()
            let year = now.year
            let month = now.month
            let day = now.day
            let hour = now.hour
            let minute = now.minute
            let second = now.second
            let dateCreated = `${day}/${month}/${year} ${hour}:${minute}`


            let AiMockChat:Chat = {
                message:"Hello there we're currently working on that, grap a cofee at the moment ",
                sender:true,
                time:dateCreated
            }

            window.setTimeout(function(){
                    setChats(prev => [...prev,AiMockChat])

            },2000)

        }


    }

    return(
        <div className="w-full fixed right-4 top-12 flex justify-end backdrop-blur-xl bg-transparent h-full py-4 md:mx-3 bg-blue-100 z-20 border-blue-600 rounded-lg select-none">
            <div className="w-[96%] sm:w-[70rem] md:w-[30rem]  h-5/6 bg-white relative rounded-lg overflow-hidden flex flex-col items-center select-none">
                <h1 className="font-bold text-xl px-4 py-4 w-[92%] mt-2 mx-auto bg-blue-200 rounded-lg text-center text-blue-600 flex gap-2 items-center justify-between "><span className="flex gap-2 items-center" ><FaInfoCircle  className="text-blue-600 text-xl" /> <span>assistant chat</span>  </span> <FaRegWindowClose onClick={cancelHandler} className="text-red-600 text-2xl justify-self-end" /></h1>
                {chat}
                <form onSubmit={submitHandler} className="w-[96%] h-12 mb-2 rounded-xl overflow-hidden bg-slate-800 flex">
                    <input name="message" className="w-4/5 h-full text-black outline-none font-bold placeholder:text-slate-600 pl-3" type="text" placeholder="start typing..."/>
                    <button className="w-1/5 h-full flex justify-center items-center" type="submit">
                        <FaTelegramPlane className="text-blue-600 text-2xl"/>
                    </button>
                </form>
            </div>
        </div>
    )
}

export function SingleChat({sender,message,time}:{sender:boolean,message:string,time:string}){

    return(
        <div className={clsx("w-5/6 h-auto p-3 pr-12 mb-4 relative rounded-lg ",{"mr-12   bg-white text-blue-600":sender == true,"ml-12 bg-black text-white":sender == false})} >
            <p className="text-md  text-left mr-4">{message}</p>
            <p className="text-sm text-slate-700 absolute bottom-1 right-2">{time.split(" ")[1]}</p>
        </div>
    )
}