//data to be transmitted
//[widget] for data needed by widget only
//[widget-current] for real-time data needed by widget which need to be transmitted all the time
//[application] for data needed by application only
//[application-start] for data needed by application only when application starts
//[application-current] for real-time data needed by application which need to be transmitted all the time
//[other] for other data which may be needed by both widget and application or for some special occasion
var photoAwdData =
{
    "urn"   : "",   //[application-widget-current]: set the current urn to sync photo detail view
}

//basic functions for handling XMLHttpRequest
var xmlHttpStartUpRequest,
    xmlHttpStandByRequest,
    xmlHttpSendDataRequest;

function initRequestInfo()
{
    xmlHttpStartUpRequest=new XMLHttpRequest();
    xmlHttpStartUpRequest.open("Get", awdAPI.getAddress("StartUp"), true);
    xmlHttpStartUpRequest.onreadystatechange = handleStartUpResponse;
    xmlHttpStartUpRequest.send(null);
}

function standByRequest()
{
    xmlHttpStandByRequest=new XMLHttpRequest();
    xmlHttpStandByRequest.open("Get", awdAPI.getAddress("StandBy"), true);
    xmlHttpStandByRequest.onreadystatechange = handleStandByResponse;
    xmlHttpStandByRequest.send(null);
}

function sendDataRequest(data)
{
    xmlHttpSendDataRequest=new XMLHttpRequest();
    xmlHttpSendDataRequest.open("Get", awdAPI.getAddress("SendData", data), true);
    xmlHttpSendDataRequest.onreadystatechange = handleSendDataResponse;
    xmlHttpSendDataRequest.send(null);
}

//converting data between JSON and object
function JSON2Obj(JSONData) {
    var myObject = JSON.parse(JSONData);
    return myObject;
}

function Obj2JSON(myObject) {
    var data = JSON.stringify(myObject, replacer);
    return data
}

function replacer(key, value) {
    if (typeof value === 'number' && !isFinite(value)) {
        return String(value);
    }
    return value;
}

function handleStandByResponse()
{
    if(xmlHttpStandByRequest.readyState == 4)
    {
        if (xmlHttpStandByRequest.status == 200)
        {
            var standByResponseData = xmlHttpStandByRequest.responseText;
            handleStandByData(standByResponseData);            
        }
    }
}

function handleSendDataResponse()
{
    if(xmlHttpSendDataRequest.readyState == 4)
    {
        if (xmlHttpSendDataRequest.status == 200)
        {
            var sendDataResponseData = xmlHttpSendDataRequest.responseText;
            handleSendData(sendDataResponseData);
        }
    }
}

function handleStartUpResponse()
{
    if(xmlHttpStartUpRequest.readyState == 4)
    {
        if (xmlHttpStartUpRequest.status == 200)
        {
            var startUpResponseData = xmlHttpStartUpRequest.responseText;
            handleStartUpData(startUpResponseData);
        }
    }
}

function handleSendData(data)
{    
    xmlHttpSendDataRequest = undefined;
}

function handleStartUpData(data)
{
    photoAwdInterface.currentData = Obj2JSON(photoAwdData);
    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = photoAwdInterface.currentData;
        console.log("My data : "+data+"\n");
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = photoAwdInterface.currentData;
    }
    standByRequest();

    photoAwdInterface.thisArrivedData = data;

    if(photoAwdInterface.lastArrivedData == photoAwdInterface.thisArrivedData && photoAwdInterface.thisArrivedData != photoAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is out-of-date. Do nothing!!\n");
    }
    else if(photoAwdInterface.thisArrivedData == photoAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is as same as current one. Do nothing!!\n");
    }
    else if(photoAwdInterface.lastArrivedData != photoAwdInterface.thisArrivedData && photoAwdInterface.thisArrivedData != photoAwdInterface.currentData) {

        photoAwdInterface.lastArrivedData = photoAwdInterface.thisArrivedData;
        console.log("[app::handleStandByData]: " + data);

        //Parse your DATA here.
        photoAwdData = JSON2Obj(data)
        photoAwdInterface.startUpControlHandle();
    }
    xmlHttpStartUpRequest = undefined;
}

function handleStandByData(data)
{
    xmlHttpStandByRequest = undefined;
    standByRequest();
    photoAwdInterface.currentData = Obj2JSON(photoAwdData);
    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = photoAwdInterface.currentData;
        console.log("My data : "+data+"\n");
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = photoAwdInterface.currentData;
    }

    photoAwdInterface.thisArrivedData = data;

    if(photoAwdInterface.lastArrivedData == photoAwdInterface.thisArrivedData && photoAwdInterface.thisArrivedData != photoAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is out-of-date. Do nothing!!\n");
    }
    else if(photoAwdInterface.thisArrivedData == photoAwdInterface.currentData) {
        console.log("[app::handleStandByData]: Data received is as same as current one. Do nothing!!\n");
    }
    else if(photoAwdInterface.lastArrivedData != photoAwdInterface.thisArrivedData && photoAwdInterface.thisArrivedData != photoAwdInterface.currentData) {

        photoAwdInterface.lastArrivedData = photoAwdInterface.thisArrivedData;
        console.log("[app::handleStandByData]: " + data);

        //Parse your DATA here.
        photoAwdData = JSON2Obj(data)
        photoAwdInterface.controlHandle();
    }
}
