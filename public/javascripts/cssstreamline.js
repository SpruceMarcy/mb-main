//written by Marcy Brook
function textToCssObject(text){
    var text1
    do{
        text1=text
        text=text.replace(/(\r\n|\n|\r)/gm,"")
        text=text.replace(/(\t|  )/gm," ")
    } while (text1!=text)
    
    var pointer1=0
    var pointer2=0
    var tempSelector=""
    var selectors=[]
    var rules=[]
    var cssOb={}
    while(pointer2<text.length){
        if(text[pointer2]=="{"){
            selectors=text.substring(pointer1,pointer2).split(",")
            for(var selector in selectors){
                selectors[selector]=selectors[selector].trim()
            }
            pointer1=pointer2+1
        }
        if(text[pointer2]=="}"){
            rules=text.substring(pointer1,pointer2).replace(/;+ *$/m, "").split(";")
            for(var rule in rules){
                rules[rule]=rules[rule].split(":")
                rules[rule]=rules[rule][0].trim()+":"+(rules[rule][1].trim())
            }
            for(let selector of selectors){
                if(typeof cssOb[selector] == 'undefined'){
                    cssOb[selector]=[]
                }
                for(let rule of rules){
                    cssOb[selector].push(rule)  
                }
            }
            pointer1=pointer2+1
        }
        pointer2++
    }
    return cssOb   
}
function cssObjectToText(cssOb){
    var text=""
    for(var selector in cssOb){
        text+=selector
        text+="{\n"
        for(var rule in cssOb[selector]){
            text+="\t"+cssOb[selector][rule]+";\n"
        }
        text+="}\n"
    }
    return text
}
function intersectionOfCssObjects(cssOb1,cssOb2){
    var intersect={}
    for(var selector1 in cssOb1){
        for(var selector2 in cssOb2){
            if(selector1==selector2){
                for(var rule1 in cssOb1[selector1]){
                    for(var rule2 in cssOb2[selector2]){
                        if(cssOb1[selector1][rule1]==cssOb2[selector2][rule2]){
                            if(typeof intersect[selector1] == 'undefined'){
                                intersect[selector1]=[]
                                //wow, I unironically got to 8 indents. nice.
                            }
                            intersect[selector1].push(cssOb1[selector1][rule1])  
                        }
                    }
                }
            }
        }
    }
    return intersect
}
document.getElementById("compare").addEventListener("click",function(){
    css1=textToCssObject(document.getElementById("input1").value)
    css2=textToCssObject(document.getElementById("input2").value)
    document.getElementById("output").value=cssObjectToText(intersectionOfCssObjects(css1,css2))
})