using CSV, DataFrames
using Plots
using SystemBenchmark
using Statistics
gr()

function report(df,scale=2.0)
    
    platforms = ["Windows", "macOS", "Linux (x86", "Linux (aarch"]
    colors = [:blue,:orange,:green,:purple]
    for col in 12:size(df,2)
        df[!,col] = df[!,col] ./ df[1,col]
    end
    
    df[!,:mean_cpu] = map(x->mean([x.FloatMul,
        x.FusedMulAdd,
        x.FloatSin,
        x.VecMulBroad,
        #x.CPUMatMul,
        x.MatMulBroad,
        x[Symbol("3DMulBroad")]]),eachrow(df))
    
    df[!,:mean_diskio] = map(x->mean([x.DiskWrite1KB,
        x.DiskWrite1MB,
        x.DiskRead1KB,
        x.DiskRead1MB]),eachrow(df))
    
    
    p1 = plot(dpi=300)
    plot!(0:100,0:100,color=:gray)
    i = 1
    for plat = platforms
        df2 = df[occursin.(plat,df.OS),:]
        scatter!(df2[!,:mean_cpu], df2[!,:compilecache], label=plat, leg=false,ms=4,markerstrokewidth=0,color=colors[i])
        xlabel!("Mean CPU time (relative to ref)")
        ylabel!("compilecache time\n(relative to ref)")
        i += 1
    end
    xlims!(0,10); ylims!(0,15)

    p2 = plot()
    plot!(0:100,0:100,color=:gray,label="parity")
    i = 1
    for plat in platforms
        df2 = df[occursin.(plat,df.OS),:]
        scatter!(df2[!,:mean_cpu],df2[!,:JuliaLoad],label=plat, legend=:best, bg_legend = :transparent, fg_legend = :transparent,ms=4,markerstrokewidth=0,color=colors[i])
        xlabel!("Mean CPU time (relative to ref)")
        ylabel!("Julia startup time\n(relative to ref)")
        i += 1
    end
    xlims!(0,10); ylims!(0,15)

    p3 = plot()
    plot!(0:100,0:100,color=:gray)
    i = 1
    for plat in platforms
        df2 = df[occursin.(plat,df.OS),:]
        scatter!(df2[!,:mean_cpu],df2[!,:mean_diskio],label=plat, fontsize=4,leg=false,ms=4,markerstrokewidth=0,color=colors[i])
        xlabel!("Mean CPU time (relative to ref)")
        ylabel!("Mean disk IO time\n(relative to ref)")
        i += 1
    end
    xlims!(0,10); ylims!(0,45)

    p4 = plot()
    plot!(0:100,0:100,color=:gray)
    i = 1
    for plat in platforms
        df2 = df[occursin.(plat,df.OS),:]
        scatter!(df2[!,Symbol("compilecache")],df2[!,Symbol("FFMPEGH264Write")],label=plat, fontsize=4,leg=false,ms=4,markerstrokewidth=0,color=colors[i])
        xlabel!("compilecache time\n(relative to ref)")
        ylabel!("FFMPEGH264Write time\n(relative to ref)")
        i += 1
    end
    xlims!(0,12); ylims!(0,12)

    plot(p1,p2,p3,p4,dpi=300,size=(400*scale,300*scale))

    savefig("summary_cropped.png")
end

df = getsubmittedbenchmarks()
savebenchmark(joinpath(@__DIR__,"all.csv"), df)
report(df)


# df = DataFrame(id=1:10,x=rand(10),y=rand(10))
# for col in 2:size(df,2)
#     df[!,col] = df[!,col] ./ df[1,col]
# end
# @show df
