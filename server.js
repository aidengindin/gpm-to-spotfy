const http = require( 'http' );
const url = require( 'url' );

http.createServer ( ( req, res ) => {
    const queryObject = url.parse( req.url, true ).query;

    res.writeHead( 200, { 'Content-Type': 'text/html' } );
    if ( queryObject.code ) {
        res.end( 'Copy and paste the following code into your terminal: ' + queryObject.code );
    } else {
        res.end( 'No code in query parameter' );
    }
}).listen(8080);
