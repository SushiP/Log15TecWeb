/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/*Draw the info of all the route's legs.*/
function RouteInfo(route){
    var dist = 0;
    var dur = 0;

    if(route){
        for(i = 0; i < route.legs.length; i++){
            dist += route.legs[i].distance.value;
            dur += route.legs[i].duration.value;
        }
    }

    this.distance = function(){return dist;};

    this.duration = function(){return dur;};

    this.distance_text = function(){
        var km = dist / 1000;

        return km + " km";
    };

    this.duration_text = function(){
        return time_to_string(dur / 60);
    };

    /*Function to convert minutes to a time string*/
    function time_to_string(time){
        var h = Math.floor(time/60);
        var m = Math.floor(time % 60);

        if(h < 10)
            h = "0" + h;

        if(m < 10)
            m = "0" + m;

        var str = h + ":" + m;

        return str;
    }
}
            
/*Variables*/
var MAXDURATION = 36000;
var map = null;
var directionsService = new google.maps.DirectionsService();
var directionsDisplay = new google.maps.DirectionsRenderer();
var matrixService = new google.maps.DistanceMatrixService();
var geocoder = new google.maps.Geocoder();
var newStart, newDest;
var placesVisited = [];
var row;

/*Create and display route. If handler is not undefined, recall it after the route has been created.*/
function create_route(origin, destination, waypoints, handler, visible){
    /*Create the request for the route.*/
    var request = {
        origin: origin,
        destination: destination,
        waypoints: waypoints,
        travelMode: google.maps.DirectionsTravelMode.DRIVING
    };

    /*Set the map in which draw the route and what to do when it's ready.*/
    directionsService.route(request, function(response, status){
        if (status == google.maps.DirectionsStatus.OK){
            var info = new RouteInfo(response.routes[0]);

            /*Draw the route.*/
            if(visible == undefined || visible == true)
                directionsDisplay.setDirections(response);

            if(handler != undefined && handler != null)
                handler(info);
        }
    });
}

/*Create a new route with two new places and when the operation is done, recall handler.*/
function create_new_route(newPlace, handler){
    newStart = newPlace[0];
    newDest = newPlace[1];

    /*Create an array with all the places to visit.*/
    var places = placesVisited.slice();
    places.push(newStart);
    places.push(newDest);

    /*Create the request for matrix distances service.*/
    var request = {
        origins: places,
        destinations: places,
        travelMode: google.maps.TravelMode.DRIVING
    };

    matrixService.getDistanceMatrix(request, function(response, status){
        if(status === google.maps.DistanceMatrixStatus.OK){
            var minDist = Number.MAX_VALUE, dijk;

            /*For every start, apply Dijkstra.*/
            for(var row = 0; row < response.rows.length; row += 2){
                dijk = Dijkstra(response.rows, row);

                /*If the returned route is the shortest one, save it.*/
                if(dijk.dist < minDist){
                    minDist = dijk.dist;
                    newRoute.start = response.originAddresses[dijk.start];
                    newRoute.destination = response.originAddresses[dijk.dest];
                    newRoute.waypoints = [];
                    for(var i = 0; i < dijk.waypoints.length; i++)
                        newRoute.waypoints.push({location: response.originAddresses[dijk.waypoints[i]]});
                } 
            }
            /*Recall the handler.*/
            handler(minDist);
        }
        else
            alert("Problemi con i servizi google, assicurarsi che vi sia connessione o riprovare più tardi.\n\
                    Errore: " + status);
    });
}

/*Search for the shortest path.*/
function Dijkstra(matrix, startInd){
    var s, e, min, currDist = 0, i, j;
    var w = [], visited = [], toVisit = [];

    /*Initialize the array of visited places.*/
    for(i = 0; i < matrix.length; i++)
        visited[i] = false;

    /*Search for the nearest place and make it the first. waypoint.*/
    toVisit.push({i: startInd, j: startInd+1});
    for(j = 0; j < matrix.length; j += 2)
        if(j != startInd)
            toVisit.push({i: startInd, j: j});

    min = search_min_matrix(matrix, toVisit);
    s = startInd;
    w[0] = min.j;
    visited[s] = true;
    visited[w[0]] = true;
    currDist += matrix[s].elements[w[0]].distance.value;

    /*For every waypoints, search the nearest one, and make it the next.
     * A destination can be visited only if its start was already visited.*/
    for(i = 0; i < matrix.length - 3; i++){
        toVisit = [];

        for(j = 0; j < matrix.length; j++)
            if(!visited[j] && (j%2 == 0 || visited[j - 1]))
                toVisit.push({i: w[i], j: j});

        min = search_min_matrix(matrix, toVisit);
        w[i+1] = min.j;

        visited[w[i+1]] = true;
        currDist += matrix[w[i]].elements[w[i+1]].distance.value;
    }

    /*The destination is the place not visited yet.*/
    for(i = 0; i < matrix.length; i++)
        if(!visited[i])
            e = i;

    currDist += matrix[w[w.length-1]].elements[e].distance.value;

    /*Return the shortest path and its length.*/
    return {start: s, dest: e, waypoints: w, dist: currDist};
}

/*Search the smallest route in the matrix rows between the places.*/
function search_min_matrix(rows, places){
    var min = Number.MAX_VALUE;
    var ret = {i: -1, j: -1};

    for(k = 0; k < places.length; k++){
        var i = places[k].i, j = places[k].j;

        if(rows[i].elements[j].distance.value < min){
            min = rows[i].elements[j].distance.value;
            ret.i = i;
            ret.j = j;
        }
    }

    return ret;
}


