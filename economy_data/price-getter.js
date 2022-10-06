// Run as snippet on: https://www.naughtynathan.co.uk/minecraft/prices.htm

var tableList = document.getElementById("ores").getElementsByTagName("tbody")[0].children;
var outArr = [];
var outStr = "";

for (let item of tableList) {    
    if (item.children[0].getAttribute('class') == "id") {
        var id = item.children[0].innerText;
        var price = item.children[3].innerText;
        var itemName = item.children[2].children[0].innerText;

        if (itemName.includes("(")) {
            console.log(itemName.replace(" (", "_").replace(")", ""))
        }
            
        outStr += itemName + ":\n";
        outStr += "    base: " + price + "\n";
        outStr += "    gov_cap: ''\n";
        outStr += "    complements: ''\n";
        outStr += "    substitutes: ''\n";
        outStr += "    rarity: ''\n";

        outArr.push({
            "price" : price,
            "item" : itemName.replace(" ", "_"),
            "id": id
        });
    }
}

console.log(outStr);
console.log(outArr);