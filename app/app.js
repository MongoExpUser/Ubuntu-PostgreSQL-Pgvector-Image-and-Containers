/* **************************************************************************************************************************************
#  * app.js                                                                                                                             *
#  **************************************************************************************************************************************
#  *                                                                                                                                    *
#  * @License Starts                                                                                                                    *
#  *                                                                                                                                    *
#  * Copyright © 2024. MongoExpUser.  All Rights Reserved.                                                                              *
#  *                                                                                                                                    *
#  *  * License: MIT - https://github.com/MongoExpUser/Ubuntu-PostgreSQL-Pgvector-Image-and-Containers/blob/main/LICENSE                *
#  *                                                                                                                                    *
#  * @License Ends                                                                                                                      *
#  **************************************************************************************************************************************
# *                                                                                                                                     *
# *  Project: Ubuntu PostgreSQl Pgvector Image & Container Project                                                                      *
# *                                                                                                                                     *
# *  This module deploys:                                                                                                               *
# *                                                                                                                                     *                                                                                                              *
# *     1)  A vanilla NodeJS HTTP or HTTPS server                                                                                       *
# *                                                                                                                                     *
# *  For Production Deployment:                                                                                                         *
# *                                                                                                                                     *
# *     1) Add relevant middlewares.                                                                                                    *
# *                                                                                                                                     *
# *     2) Add NodeJS Weather Application route.                                                                                        *
# *                                                                                                                                     *                                                                                                                                  *
# *     3) Add relevant web server codes (.html, .css and .js codes).                                                                   *
# *                                                                                                                                     *                                                                                                                             *
# *  Note:                                                                                                                              *
# *                                                                                                                                     *
# *     1) This module is a demo. Hence, relevant middlewares' and routes' proprietary codes have been removed or commented out         *
# *                                                                                                                                     *
# *     2) Irrespective of open or proprietary implementations, the program's architecture remains thesame.                             *
# *                                                                                                                                     *
# *     3) Node.js version: 21                                                                                                          *
# *        Invoke as:sudo node --inspect=$((9233 + $RANDOM % 100)) --trace-warnings --trace-deprecation --watch app.js                  *
# *                                                                                                                                     *
# **************************************************************************************************************************************/


class AppVanilla
{
    constructor()
    {
        // import internal and external modules

        // internal
        const emitter   = require("events");                            // globally turn off limits on maximum listeners for any event:
        emitter.EventEmitter.defaultMaxListeners = 0                    // to be effective: should be 1st line of code in app.js
        const os = require("os");
        const util = require("util");
        //const https = require("https");                               // for tls/ssl deployment
        const http = require("http");
        const cluster = require("cluster");
        
        // external
        //const spdy = require("spdy");                                 // create HTTP2 / SPDY servers in node.js and can be used in place of https -- for tls/ssl deployment
        //const modulesBaseDir  = "./baseDir"
        //const objs = require(`${modulesBaseDir}/CommonObjects.js`);   // commonly used objects

        //define variables
        const port = 80;
        const sslPort = 443;
        const host = "localhost";
        const get  = "GET";
        const post = "POST";
        const put  = "PUT";
        const del  = "DELETE";
        const validMethodlist = [get, post, put, del];
        
        function commonLongDateFormat()
        {
            return { weekday: "long", year: "numeric", month: "long", day: "numeric", hour: "2-digit", minute: "2-digit", second: "2-digit"};
        }
        
        function clusterStartMaster(cluster, os, util)
        {
            // set-up system for multi-core system: launch a cluster of Node.js processes to handle the load on multi-core
            const  extraWorker = 1;
            const numCPUs = os.cpus().length;
            const numWorkers = numCPUs + extraWorker;
            const infCPUs =  os.cpus();
            console.log("  ");
            console.log("Starting Node.js https-server(s)");
            console.log("=================================");
            console.log("Nos. of CPUs     : ", numCPUs);                                          // log the number of CPU/core installed.
            console.log("Nos. of Workers  : ", numWorkers);                                       // log the number of CPU/core installed.
            console.log("Inf. of CPUs  : ", JSON.stringify(infCPUs));                             // log information about each CPU/core installed.
            console.log("Inf. of CPUs     : ");                                                   // log information about each CPU/core installed.
            console.log(util.inspect(infCPUs, false, null) );                                     // log information about each CPU/core installed.
            console.log("   ");
            console.log("I am the Master (" + process.pid + "): now lauching workers!");          // log confirmation of master start-up
            console.log("   ");
            

            // create (fork) workers/processes
            for(let index = 1; index <= numWorkers; index++)
            {
                cluster.fork();                                                                    // create worker
                console.log("Worker No. " + (index) + " Information");                             // log information about each worker
                console.log("=================================");
                console.log("Worker OS CPU architecture  : " + os.arch());                         // log the os CPU/core architecture.
                console.log("Worker OS platform          : " + os.platform());                     // log the os platform/name/type
                console.log("Worker OS release           : " + os.release());                      // log the os release.
                console.log("Worker OS free memory       : " + os.freemem());                      // log the os free memory.
                console.log("Worker OS total memory      : " + os.totalmem());                     // log the os total memory.
                console.log("=================================");
            }
        
            cluster.on("online", function(worker, code, signal)
            {
                // note: time is GMT
                const pid = worker.process.pid;
                console.log( `I am  a worker (${pid}) now running! GMT is : ${(new Date()).toLocaleTimeString("en-us", commonLongDateFormat())}`  );
        
            }).setMaxListeners(0); //handles max event emmitter error;
        
            cluster.on("exit", function(worker, code, signal)
            {
                if(worker.exitedAfterDisconnect === true)           //voluntary exit
                {
                    console.log("Voluntary exit – no wahala!");
                }
                else                                                //involuntary/accidental
                {
                    const pid = worker.process.pid;
                    console.log(`Restarting worker (${pid}) with code: ${code} and signal: ${signal}`);
                    cluster.fork();
                }
        
            }).setMaxListeners(0); //handles max event emmitter error;
        
            cluster.on("message", function (msgEvent)
            {
                //graceful close (shutdown) of any connections to server
                if (msgEvent === "shutdown")
                {
                    const pid = worker.process.pid;
                    console.log(`Worker (${pid}) is now disconnected from MASTER/PRIMARY through app termination`);
                    process.exit(0);
                }
        
            }).setMaxListeners(0); //handles max event emmitter error
      
        }

        // create server as IIFE
        (function createServer()
        {
            if(cluster.isMaster)
            {
                clusterStartMaster(cluster, os, util);
            }
            else
            {
                //const secureServer = spdy.createServer(objs.commonOptionsSSL(), function handleRequest(request, response)  // -- for tls/ssl deployment (option 1) - for http2 features
                //const secureServer = https.createServer(objs.commonOptionsSSL(), function handleRequest(request, response) // -- for tls/ssl deployment (option 2) 
                const server = http.createServer(function handleRequest(request, response)
                {
                    // common variables
                    let method = (request.method).toUpperCase();
                    let url = request.url;
                    //let createdMiddlewares = objs.commonModules();
                    //let createdRoutes = objs.commonModules();
                    //let staticFileOptions =  objs.commonVariables().staticFileOptions;
                    let body = [];
                
                    // 1. parse body (i.e add body to request) - simple body parser
                    request.on("error", function (err)
                    {
                      console.error(err);
                    });
                            
                    request.on("data", function (data)
                    {
                        body.push(data);
                    });
                            
                    request.on("end", function ()
                    {
                        if(body)
                        {
                            body = Buffer.concat(body).toString();
                            request.body = body;
                        }
                        
                        // 2. other middlewares
                        //createdMiddlewares.CompressionVanilla(request, response);                           // compression middleware
                        //createdMiddlewares.SecurityVanilla(request, response);                              // security middleware, like helmet
                        //createdMiddlewares.LoggerVanilla(request, response);                                // logger middlware, like morgan
                        //createdMiddlewares.BasicAuthenticationVanilla(request, response);                   // basic authentication middleware: should come after "logger" middleware (optional)

                        // 3. routes
                        //add more routes as deem necessary
                        // ..
                        // ..
                        //createdRoutes.ServeStaticFilesVanilla(get, request, response, staticFileOptions);   // static file server as routes: should come last
                        
                        
                        // serve html response example (for testing)
                        const html = "<html><center><p><h2>Successful Web Server Deployment!</h2><p/></center></html>";
                        response.writeHead(200, { "Content-Type" : "text/html" });
                        response.end(html);
                    
                    });
                });

                //secureServer.listen(sslPort, function listenOnServer() { console.log(`Server listening on https://${host}:${sslPort}/ ...`) }).setMaxListeners(0); // -- for tls/ssl deployment
                server.listen(port, function listenOnServer() { console.log(`Server listening on https://${host}:${port}/ ...`) }).setMaxListeners(0);
            }

        })();

    }
}

new AppVanilla();


module.exports = { AppVanilla }
