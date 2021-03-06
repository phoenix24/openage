#version 120

//team color replacement shader
//
//looks for an alpha value specified by 'alpha_marker'
//and then replaces this pixel with the desired color,
//tinted for player_number, and using the given color as base.

//the unmodified texture itself
uniform sampler2D texture;

//the desired player number the final resulting colors
uniform int player_number;

//the alpha value which marks colors to be replaced
uniform float alpha_marker;

//color entries for all players and their subcolors
uniform vec4 player_color[64];

//interpolated texture coordinates sent from vertex shader
varying vec2 tex_position;

//create epsilon environment for float comparison
const float epsilon = 0.001;

//do the lookup in the player color table
//for a playernumber (red, blue, etc)
//get the subcolor (brightness variations)
vec4 get_color(int playernum, int subcolor) {
	return player_color[((playernum-1) * 8) + subcolor];
}

//compare color c1 to a reference color
bool is_color(vec4 c1, vec4 reference) {
	if (all(greaterThanEqual(c1, reference - epsilon)) && all(lessThanEqual(c1, reference + epsilon))) {
		return true;
	}
	else {
		return false;
	}
}


void main() {
	//get the texel from the uniform texture.
	vec4 pixel = texture2D(texture, tex_position);

	//check if this texel has an alpha marker, so we can replace it's rgb values.
	if (pixel[3] >= alpha_marker - epsilon && pixel[3] <= alpha_marker + epsilon) {

		//set alpha to 1 for the comparison
		pixel[3] = 1.0;

		//don't replace the colors if it's already player 1 (blue)
		//as the media convert scripts generates blue-player sprites
		if (player_number != 1) {
			bool found = false;

			//try to find the base color, there are 8 of them.
			for(int i = 0; i <= 7; i++) {
				if (is_color(pixel, player_color[i])) {
					//base color found, now replace it with the same color
					//but player_number tinted.
					pixel = get_color(player_number, i);
					found = true;
					break;
				}
			}
			if (!found) {
				//unknown base color gets pink muhahaha
				pixel = vec4(255.0/255.0, 20.0/255.0, 147.0/255.0, 1.0);
			}
		}
	}
	//else the texel had no marker so we can just draw it without player coloring

	gl_FragColor = pixel;
}
