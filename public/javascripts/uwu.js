//Written by Marcy Brook. I'm so sorry.

document.getElementById("translate").addEventListener("click",function(){
    text=document.getElementById("input").value
    r=[[,]]
    r.push([/[rl]/gi,"w"])
    r.push([/youw/gi,"ur"])
    r.push([/you/gi,"u"])
    r.push([/awe /gi,"r "])
    r.push([/ove/gi,"uv"])
    r.push([/(n)([aeiou])/gi,"$1y$2"])
    for(var pair in r) {
        text=text.replace(r[pair][0], r[pair][1]);
        
    }
    document.getElementById("output").value=text
})

