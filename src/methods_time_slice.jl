module MethodsTimeSlice

using ..StructTimeSlice

function Base.getproperty(slice::TimeSlice, symb::Symbol)
    if symb in fieldnames(TimeSlice)
        return getfield(slice, symb)
    else
        indices = slice.components[symb]
        return slice.data[indices]
    end
end

function Base.getindex(slice::TimeSlice, symb::Symbol)
    if symb in fieldnames(TimeSlice)
        return getfield(slice, symb)
    else
        indices = slice.components[symb]
        return slice.data[indices]
    end
end



end
