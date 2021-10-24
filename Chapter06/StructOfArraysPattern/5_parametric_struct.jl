using BenchmarkTools, Statistics, CSV, StructArrays, Parameters
using Base

abstract type TripSize end
struct Small <: TripSize end
struct Large <: TripSize end

@with_kw struct TripPayment{T<:TripSize}
    vendor_id::Int
    tpep_pickup_datetime::String
    tpep_dropoff_datetime::String
    passenger_count::Int
    trip_distance::Float64
    fare_amount::Float64
    extra::Float64
    mta_tax::Float64
    tip_amount::Float64
    tolls_amount::Float64
    improvement_surcharge::Float64
    total_amount::Float64
    size::T
end


TripPayment{T}(vendor_id::Int, tpep_pickup_datetime::String, tpep_dropoff_datetime::String, passenger_count::Int,
    trip_distance::Float64, fare_amount::Float64, extra::Float64, mta_tax::Float64, tip_amount::Float64,
    tolls_amount::Float64, improvement_surcharge::Float64, total_amount::Float64, size::T) where T<:Union{Large, Small} = TripPayment{T}(
        vendor_id, tpep_pickup_datetime, tpep_dropoff_datetime, passenger_count,
        trip_distance, fare_amount, extra, mta_tax, tip_amount, tolls_amount, 
        improvement_surcharge, total_amount, size)


# Base.fieldnames(::Type{TripPayment{<:Union{Small, Large}}}) = fieldnames(TripPayment{Large})


# Use CVS.jl to parse the file into a vector of TripPayment objects
function read_trip_payment_file(file)
    f = CSV.File(file, datarow = 3)
    records = Vector{TripPayment{<:Union{Small, Large}}}(undef, length(f))
    for (i, row) in enumerate(f)
        if row.passenger_count <= 2
            size = Small()
        else
            size = Large()
        end
        records[i] = TripPayment(row.VendorID,
                                 row.tpep_pickup_datetime, 
                                 row.tpep_dropoff_datetime,
                                 row.passenger_count,
                                 row.trip_distance,
                                 row.fare_amount,
                                 row.extra,
                                 row.mta_tax,
                                 row.tip_amount,
                                 row.tolls_amount,
                                 row.improvement_surcharge,
                                 row.total_amount,
                                 size)
    end
    return records
end

records = read_trip_payment_file("yellow_tripdata_2018-12_100k.csv")

sa = StructArray(records);


