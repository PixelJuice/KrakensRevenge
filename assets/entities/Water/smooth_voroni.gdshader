shader_type spatial;

// vec2 to vec2 hash.
vec2 hash22(vec2 p) { 

    // Faster, but doesn't disperse things quite as nicely. However, when framerate
    // is an issue, and it often is, this is a good one to use. Basically, it's a tweaked 
    // amalgamation I put together, based on a couple of other random algorithms I've 
    // seen around... so use it with caution, because I make a tonne of mistakes. :)
    float n = sin(dot(p, vec2(41, 289)));
    //return fract(vec2(262144, 32768)*n); 
    
    // Animated.
    p = fract(vec2(262144, 32768)*n); 
    // Note the ".333," insted of ".5" that you'd expect to see. When edging, it can open 
    // up the cells ever so slightly for a more even spread. In fact, lower numbers work 
    // even better, but then the random movement would become too restricted. Zero would 
    // give you square cells.
    return sin( p*6.2831853 + TIME)*.333 + .333; 
    //return sin( p*6.2831853 + iTime*2.)*(cos( p*6.2831853 + iTime*.5)*.3 + .5)*.45 + .5; 
    
}

// IQ's smooth minimum function.
float smin(float a, float b, float k){

    float h = clamp(.5 + .5*(b - a)/k, 0., 1.);
    return mix(b, a, h) - k*h*(1. - h);
}

// 2D 2nd-order Voronoi: Obviously, this is just a rehash of IQ's original. I've tidied
// up those if-statements. Since there's less writing, it should go faster. That's how 
// it works, right? :)
//
// This is exactly like a regular Voronoi function, with the exception of the smooth
// distance metrics.
float Voronoi(in vec2 p){
    
    // Partitioning the grid into unit squares and determining the fractional position.
	vec2 g = floor(p), o; p -= g;
	
    // "d.x" and "d.y" represent the closest and second closest distances
    // respectively, and "d.z" holds the distance comparison value.
	vec3 d = vec3(8); // 8., 2, 1.4, etc. 
    
     
    
    // A 4x4 grid sample is required for the smooth minimum version.
	for(float j = -1.; j <= 2.; j++){
		for(float i = -1.; i <= 2.; i++){
            
			o = vec2(i, j); // Grid reference.
             // Note the offset distance restriction in the hash function.
            o += hash22(g + o) - p; // Current position to offset point vector.
            
            // Distance metric. Unfortunately, the Euclidean distance needs
            // to be used for clean equidistant-looking cell border lines.
            // Having said that, there might be a way around it, but this isn't
            // a GPU intensive example, so I'm sure it'll be fine.
			d.z = length(o); 
            
            
            // Up until this point, it's been a regular Voronoi example. The only
            // difference here is the the mild smooth minimum's to round things
            // off a bit. Replace with regular mimimum functions and it goes back
            // to a regular second order Voronoi example.
            d.y = max(d.x, smin(d.y, d.z, .4)); // Second closest point with smoothing factor.
            
            d.x = smin(d.x, d.z, .2); // Closest point with smoothing factor.
            
            // Based on IQ's suggestion - A commutative exponential-based smooth minimum.
            // This algorithm is just an approximation, so it doesn't make much of a difference,
            // but it's here anyway.
            //d.y = max(d.x, sminExp(d.y, d.z, 10.)); // Second closest point with smoothing factor.
            //d.x = sminExp(d.x, d.z, 20.); // Closest point with smoothing factor.

                       
		}
	}    
	
    // Return the regular second closest minus closest (F2 - F1) distance.
    return d.y - d.x;
    
}

void fragment() {
	
	// Screen coordinates.
	vec2 uv = UV;
    //
    // Mild, simplistic fisheye effect.
    //uv *= (.9 + length(uv)*.2);
    //
    // Scrolling action.
    uv -= TIME*vec2(1, .25)/8.;
	
	vec3 voronoi = vec3(Voronoi(uv*5.));
	voronoi *= smoothstep(0., .00001, voronoi);
	ALBEDO = vec3(voronoi);
}
