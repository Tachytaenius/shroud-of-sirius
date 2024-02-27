// This shader must be loaded with the lib/simplex3d include glsl file concatenated to the beginning

const float tau = 6.28318530718;

float calculateFogFactor(float dist, float maxDist, float fogFadeLength) { // More fog the further you are
	if (fogFadeLength == 0.0) { // Avoid dividing by zero
		return dist < maxDist ? 0.0 : 1.0;
	}
	return clamp((dist - maxDist + fogFadeLength) / fogFadeLength, 0.0, 1.0);
}

float calculateFogFactor2(float dist, float fogFadeLength) { // More fog the closer you are
	if (fogFadeLength == 0.0) { // Avoid dividing by zero
		return 1.0; // Immediate fog
	}
	return clamp(1 - dist / fogFadeLength, 0.0, 1.0);
}

float pingPong(float x, float height) {
	return height - abs(height - mod(x, 2.0 * height));
}

float jaggedify(float x, float mul1, float mul2, float height, float add) {
	return mul1 * x + mul2 * pingPong(x, height) + add;
}

float bumpify(float x, float a, float b, float c, float d) {
	return a * x + b * sin(c * d) + d;
}

vec3 hsv2rgb(vec3 hsv) {
	float h = hsv[0];
	float s = hsv[1];
	float v = hsv[2];
	if (s == 0.0) {
		return vec3(v);
	}
	float _h = h / 60.0;
	int i = int(_h);
	float f = _h - i;
	float p = v * (1 - s);
	float q = v * (1 - f * s);
	float t = v * (1 - (1 - f) * s);
	if (i == 0) {
		return vec3(v, t, p);
	} else if (i == 1) {
		return vec3(q, v, p);
	} else if (i == 2) {
		return vec3(p, v, t);
	} else if (i == 3) {
		return vec3(p, q, v);
	} else if (i == 4) {
		return vec3(t, p, v);
	} else if (i == 5) {
		return vec3(v, p, q);
	}
}

vec3 sampleSky(
	vec3 direction, float time,
	vec3 starColour, vec3 starDirection, float starAngularRadius, float starHaloAngularRange
) {
	vec3 directionOriginal = direction;
	direction.z /= 4.0;
	direction = normalize(direction);
	vec3 directionJagged = vec3(
		jaggedify(direction.x * 10.0, 2.0, 1.5, 1.0, -4.0) / 10.0,
		jaggedify(direction.y * 10.0, 1.9, 1.6, 1.1, -2.0) / 10.0,
		jaggedify(direction.z * 10.0, 1.8, 1.7, 1.2, sin(time / 2.5) * 0.25) / 10.0
	);
	vec3 directionBumpified = vec3(
		bumpify(direction.x, 0.1, 0.2, 0.3, 0.4),
		bumpify(direction.y, -1.0, 1.0, 2.0, 3.0),
		bumpify(direction.z, 4.0, 3.0, 2.0, 1.0)
	);
	vec3 directionMixedModulated = direction + dot(directionJagged, directionBumpified) - cos(time * 0.2 + cos(time * 0.2)) * 0.3 * cross(directionJagged, directionBumpified);
	vec3 directionMixedRipples = direction + dot(directionJagged, directionBumpified) - cos(time * 0.3 + simplex3d(directionOriginal * 1.0 + vec3(0.0, 0.0, time * 0.05)) * tau) * 0.3 * cross(directionJagged, directionBumpified);
	vec3 directionMixedMixed = mix(directionMixedRipples, directionMixedModulated, sin(time * 0.25) * 0.5 + 0.5);
	float whiteness = max(
		calculateFogFactor2(distance(direction, vec3(0, 0, -1)), 0.75),
		calculateFogFactor2(distance(direction, vec3(0, 0, 1)), 1.0)
	);
	vec3 baseSkyColour =
		(sin(time * 0.5) * 0.5 + 0.5 + 0.25) * (
			vec3(
				pow(simplex3d(directionMixedMixed * 0.5 + 0.0 - time * 0.25), 2.0),
				pow(simplex3d(directionMixedMixed * 0.5 + 10.0 - time * 0.5), 2.0),
				pow(simplex3d(directionMixedMixed * 0.5 + 100.0 + time * 0.1), 2.0)
			)
		)
		+
		(sin(time * 0.3 + tau / 8) * 0.5 + 0.5 + 0.5) * (
			1.25 * vec3(
				pow(simplex3d(direction * 1.0 - time * 0.025), 2.0),
				pow(simplex3d(direction * 2.0 - time * 0.05), 2.0),
				pow(simplex3d(direction * 3.0 + time * 0.1), 2.0)
			)
		)
		+
		hsv2rgb(vec3(
			mod(simplex3d(directionBumpified * 1.0) + time * 0.1, 1.0) * 360.0,
			1.0,
			pow(simplex3d(directionJagged * 5.0 + 10.0), 1.0)
		))
	;
	vec3 baseSkyColourPow = vec3(
		pow(clamp(baseSkyColour.r, 0.0, 1.0), 1.0 + sin(time * 0.3 + 0.25) * 0.5 + 0.5),
		pow(clamp(baseSkyColour.g, 0.0, 1.0), 1.0 + sin(time * 0.3 + 0.25) * 0.5 + 0.5),
		pow(clamp(baseSkyColour.b, 0.0, 1.0), 1.0 + sin(time * 0.3 + 0.25) * 0.5 + 0.5)
	);

	float dotResult = dot(directionOriginal, starDirection);
	float dotResultClamped = clamp(dotResult, -1.0, 1.0); // Clamping because, at least on the CPU, sometimes precision would cause dot to return a result outside of [-1, 1], breaking acos
	float angleDistance = abs(acos(dotResult));
	float starEffectAmount = 1.0 - calculateFogFactor(angleDistance, starAngularRadius + starHaloAngularRange, starHaloAngularRange);
	starEffectAmount = max(starEffectAmount - (1.0 - starEffectAmount) * pow(simplex3d(directionOriginal * 24.0 + time * 0.5 * starDirection) * 0.5 + 0.5, 2.0), 0.0);

	vec3 skyColour = mix(mix(baseSkyColourPow, vec3(1.0), whiteness), starColour, starEffectAmount);
	return skyColour;
}
