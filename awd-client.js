/***************************************** Read Me ******************************************/
/*  [ Usage & Sample ]                                                                      */
/*                                                                                          */
/*  Fill awdName and awdType                                                                */
/*  awdName for your application/widget name                                                */
/*  awdType for your application/widget type. Either app or widget will be accepted         */
/*                                                                                          */
/*  import "awd-client.js" as Awd                                                           */
/*  Add initRequestInfo() function in your initialization                                   */
/*  Add destRequestInfo() function in your destruction                                      */
/*  Modify sendMyData(data) function and use it send your data for communication            */
/*                                                                                          */
/***************************************** Carefully ****************************************/

var xmlHttpStartUpRequest,  //For the very first request, inform server your starting and get your init data back.
    xmlHttpShutDownRequest, //For the last request before you shut down, inform server and save your data.
    xmlHttpStandByRequest,  //Request every time after you get a data so that you are able to get it again when there
                            //is new data available on the server.
    xmlHttpSendDataRequest; //Send your current data to the server.This request should better be only sent once a time when
                            //there is an operation which is made by human!!

//Add this one on your initialization. Like: Component.onCompleted: {}
//It should be used only once!!
function initRequestInfo()
{
    xmlHttpStartUpRequest=new XMLHttpRequest();
    xmlHttpStartUpRequest.open("Get", awdAPI.getAddress("StartUp"), true);
    xmlHttpStartUpRequest.onreadystatechange = handleStartUpResponse;
    xmlHttpStartUpRequest.send(null);
}

//Add this one on your end. Like: Component.onDestruction: {}
function destRequestInfo()
{
    xmlHttpShutDownRequest=new XMLHttpRequest();
    xmlHttpShutDownRequest.open("Get", awdAPI.getAddress("ShutDown"), true);
    xmlHttpShutDownRequest.onreadystatechange = handleShutDownResponse;
    xmlHttpShutDownRequest.send(null);
}

//I have already added this one for you. You'd better not use it unless you know exactly what you are doing!!
function standByRequest()
{
    xmlHttpStandByRequest=new XMLHttpRequest();
    xmlHttpStandByRequest.open("Get", awdAPI.getAddress("StandBy"), true);
    xmlHttpStandByRequest.onreadystatechange = handleStandByResponse;
    xmlHttpStandByRequest.send(null);
}

//Use this one send your DATA
function sendDataRequest(data)
{
    xmlHttpSendDataRequest=new XMLHttpRequest();
    xmlHttpSendDataRequest.open("Get", awdAPI.getAddress("SendData", data), true);
    xmlHttpSendDataRequest.onreadystatechange = handleSendDataResponse;
    xmlHttpSendDataRequest.send(null);
}

//These two are not necessary. Just in case someone don't know how to use "JSON.parse" and "JSON.stringify".
//Using just "JSON.parse" and "JSON.stringify" are recommended.
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

//Handling all the four kinds of response.
//You'd better not use these four function unless you know exactly what you are doing!!
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

function handleShutDownResponse()
{
    if(xmlHttpShutDownRequest.readyState == 4)
    {
        if (xmlHttpShutDownRequest.status == 200)
        {
            var shutDownResponseData = xmlHttpShutDownRequest.responseText;
            handleShutDownData(shutDownResponseData);
        }
    }
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
            handleSendDataData(sendDataResponseData);
        }
    }
}

function handleShutDownResponse(data)
{
    //Handling "ShutDown" data.
    //In fact, nothing to do. You are already shut down!!
    console.log("[Shut down response]: \n" + data);
}

function handleSendDataData(data)
{
    //This one is usually just for debugging.
    console.log("[Send data response]: \n" + data);
}

//============================ [ Your own data handling fuctions ] ============================//

function handleStartUpData(data)
{
    console.log("------------------------------------------------------------ handleStartUpData(data) : " + data +"\n");
    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.uid) {
            console.log("Wrong application don't need uid: "+recoverTest.uid+"\n");
        }
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = 0;
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = 0;
    }

    //Parse your initial data here.
    //probably it's almost the same as handling "StandBy" response data.
    //This data you get is for your initialization.
    //Your application's initialization probably need become two parts:
    //init something -> request initial data -> finish initialization
    var dataString = String(data);

    //Record data for avoiding send data repeatly
    scene.lastArrivedData = dataString;
    console.log("------------------------------------------------------------ scene.lastArrivedData : " + scene.lastArrivedData +"\n");
    scene.inDetailPage = false;
    scene.setCurrentPhotoIndex(JSON.parse(data));

    //Send "StandBy" request again.
    //You can change the request time by moving it.
    standByRequest();

}

function handleStandByData(data)
{
    //Send "StandBy" request again.
    //You can change the request time by moving it.
    standByRequest();

    try {
        var recoverTest = JSON.parse(data);
        if(recoverTest.uid) {
            console.log("Wrong app don't need uid: "+recoverTest.uid+"\n");
        }
        if(recoverTest.currentContext) {
            data = recoverTest.currentContext.data;
        }
        if(recoverTest.anotherContext) {
            data = recoverTest.anotherContext.data;
        }
        if(data === "" || !data)
            data = 0;
    }
    catch(error) {
        console.log("Catch error... set back to default value~~~\n")
        data = 0;
    }

    //Parse your data here.
    //Do whatever you like!!
    //But remember: don't get the process stuck!!
    var dataString = String(data);

    //Record data for avoiding send data repeatly
    scene.lastArrivedData = dataString;
    scene.setCurrentPhotoIndex(data);
}

//Only this one, you may change the function name, arguments or whatever.
//But don't change the sentence I have done for you unless you know exactly what you are doing!!
function sendMyData(data)
{
    //Pick your data.
    //Pack them to JSON or whatever.
    //Send them!!
    var dataString = String(data);
    //Compare data for avoiding send data repeatly

    if(scene.isFirstStart) {
        if(data <= 0 || dataString == scene.lastArrivedData)
            return;
        else
            scene.isFirstStart = false;
    }

    if(!(dataString.indexOf(scene.lastArrivedData)==0 && scene.lastArrivedData.indexOf(dataString)==0)) {
        sendDataRequest(data);
        scene.lastArrivedData = dataString;
    }
}

function getInitIndex()
{
    initRequestInfo();
    return Number(scene.lastArrivedData);
}
