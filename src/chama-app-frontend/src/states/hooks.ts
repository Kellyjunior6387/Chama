import { TypedUseSelectorHook,useDispatch,useSelector } from "react-redux";
import type {RootState,AppDispatch} from "./reduxStore"


export const useAppDispatch:() => AppDispatch = useDispatch

export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector