function insertAfter(newNode, referenceNode) {
    referenceNode.parentNode.insertBefore(newNode, referenceNode.nextSibling);
}

var ems = document.getElementsByTagName('em')
console.log(ems.length)
for (var e in ems) {
    if (e == "item" || e == "namedItem" || e == "length") continue
    if (ems[e].nextSibling.nodeValue.substr(0, 1) == ":") continue
    var sp = document.createElement("span")
    sp.innerText = ems[e].nextSibling.nodeValue.match(/ \w+\b/)
    if (ems[e].nextSibling.nodeValue.match(/ \w+\b./) == sp.innerText + "(") sp.className = "func"
    else sp.className = "name"
    ems[e].nextSibling.nodeValue = ems[e].nextSibling.nodeValue.replace(sp.innerText, "")
    insertAfter(sp, ems[e])
}

var lis = document.getElementsByClassName("wy-nav-content")[0].querySelectorAll("ul > li > ul > li");
console.log(lis.length)
for (var l in lis) {
    console.log(lis[l].innerHTML)
    if (lis[l].innerHTML == null) continue
    if (lis[l].innerText.match(/\w+\b:/) == null) continue;
    var sp = document.createElement("span")
    sp.className = "name_desc"
    sp.innerText = lis[l].innerText.match(/\w+\b/)
    lis[l].innerText = lis[l].innerText.replace(sp.innerText, "")
    var n = document.createTextNode(lis[l].innerText)
    lis[l].innerText = ""
    lis[l].appendChild(n)
    lis[l].insertBefore(sp, n)
    console.log(lis[l].innerHTML)
}

var cs = document.getElementsByClassName("wy-nav-content")[0].querySelectorAll("#constructor + p + ul > li");
console.log(cs.length)
for (var c in cs) {
    console.log(cs[c].innerHTML)
    if (cs[c].innerHTML == null) continue
    var sp = document.createElement("span")
    sp.className = "name_desc"
    sp.innerText = cs[c].innerText.match(/\w+\b/)
    cs[c].innerText = cs[c].innerText.replace(sp.innerText, "")
    var n = document.createTextNode(cs[c].innerText)
    cs[c].innerText = ""
    cs[c].appendChild(n)
    cs[c].insertBefore(sp, n)
    console.log(cs[c].innerHTML)
}

cs = document.getElementsByClassName("wy-nav-content")[0].querySelectorAll("#events + p + ul > li");
console.log(cs.length)
for (var c in cs) {
    console.log(cs[c].innerHTML)
    if (cs[c].innerHTML == null) continue
    var sp = document.createElement("span")
    sp.className = "name_desc"
    sp.innerText = cs[c].innerText.match(/\w+\b/)
    cs[c].innerText = cs[c].innerText.replace(sp.innerText, "")
    var n = document.createTextNode(cs[c].innerText)
    cs[c].innerText = ""
    cs[c].appendChild(n)
    cs[c].insertBefore(sp, n)
    console.log(cs[c].innerHTML)
}