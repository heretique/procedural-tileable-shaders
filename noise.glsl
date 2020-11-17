// 1D Value noise.
// @param scale Number of tiles, must be an integer for tileable results, range: [2, inf]
// @param seed Seed to randomize result, range: [0, inf]
// @return Value of the noise, range: [-1, 1]
float noise(float pos, float scale, float seed)
{
    pos *= scale;
    vec2 i = floor(pos) + vec2(0.0, 1.0);
    float f = pos - i.x;
    i = mod(i, vec2(scale)) + seed;

    float u = noiseInterpolate(f);
    return mix(hash1D(i.x), hash1D(i.y), u) * 2.0 - 1.0;
}

// 2D Value noise.
// @param scale Number of tiles, must be an integer for tileable results, range: [2, inf]
// @param seed Seed to randomize result, range: [0, inf]
// @return Value of the noise, range: [-1, 1]
float noise(vec2 pos, vec2 scale, float seed) 
{
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec2 f = pos - i.xy;
    i = mod(i, scale.xyxy) + seed;

    vec4 hash = multiHash2D(i);
    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;

    vec2 u = noiseInterpolate(f);
    float value = mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
    return value * 2.0 - 1.0;
}

// 2D Value noise.
// @param scale Number of tiles, must be an integer for tileable results, range: [2, inf]
// @param phase The phase for rotating the hash, range: [0, inf], default: 0.0
// @param seed Seed to randomize result, range: [0, inf]
// @return Value of the noise, range: [-1, 1]
float noise(vec2 pos, vec2 scale, float phase, float seed) 
{
    const float kPI2 = 6.2831853071;
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec2 f = pos - i.xy;
    i = mod(i, scale.xyxy) + seed;

    vec4 hash = multiHash2D(i);
    hash = 0.5 * sin(phase + kPI2 * hash) + 0.5;
    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;

    vec2 u = noiseInterpolate(f);
    float value = mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
    return value * 2.0 - 1.0;
}

// 2D Value noise with derivatives.
// @param scale Number of tiles, must be an integer for tileable results, range: [2, inf]
// @param seed Seed to randomize result, range: [0, inf]
// @return x = value of the noise, yz = derivative of the noise, range: [-1, 1]
vec3 noised(vec2 pos, vec2 scale, float seed) 
{
    // value noise with derivatives based on Inigo Quilez
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec2 f = pos - i.xy;
    i = mod(i, scale.xyxy) + seed;

    vec4 hash = multiHash2D(i);
    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;
    
    vec4 udu = noiseInterpolateDu(f);    
    float abcd = a - b - c + d;
    float value = a + (b - a) * udu.x + (c - a) * udu.y + abcd * udu.x * udu.y;
    vec2 derivative = udu.zw * (udu.yx * abcd + vec2(b, c) - a);
    return vec3(value * 2.0 - 1.0, derivative);
}

// 2D Value noise with derivatives.
// @param scale Number of tiles, must be an integer for tileable results, range: [2, inf]
// @param phase The phase for rotating the hash, range: [0, inf], default: 0.0
// @param seed Seed to randomize result, range: [0, inf]
// @return x = value of the noise, yz = derivative of the noise, range: [-1, 1]
vec3 noised(vec2 pos, vec2 scale, float phase, float seed) 
{
    const float kPI2 = 6.2831853071;
    // value noise with derivatives based on Inigo Quilez
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec2 f = pos - i.xy;
    i = mod(i, scale.xyxy) + seed;

    vec4 hash = multiHash2D(i);
    hash = 0.5 * sin(phase + kPI2 * hash) + 0.5;
    float a = hash.x;
    float b = hash.y;
    float c = hash.z;
    float d = hash.w;
    
    vec4 udu = noiseInterpolateDu(f);    
    float abcd = a - b - c + d;
    float value = a + (b - a) * udu.x + (c - a) * udu.y + abcd * udu.x * udu.y;
    vec2 derivative = udu.zw * (udu.yx * abcd + vec2(b, c) - a);
    return vec3(value * 2.0 - 1.0, derivative);
}

// 3D Value noise with height that is tileable on the XY axis.
// @param scale Number of tiles, must be an integer for tileable results, range: [2, inf]
// @param time The height phase for the noise value, range: [0, inf], default: 0.0
// @param seed Seed to randomize result, range: [0, inf], default: 0.0
// @return Value of the noise, range: [-1, 1]
float noise3d(vec2 pos, vec2 scale, float height, float seed)
{
    // classic value noise with 3D
    pos *= scale;
    vec3 i = floor(vec3(pos, height));
    vec3 ip1 = i + vec3(1.0);
    vec3 f = vec3(pos, height) - i;
    
    vec4 mi = mod(vec4(i.xy, ip1.xy), scale.xyxy);
    i.xy = mi.xy;
    ip1.xy = mi.zw;

    vec4 hashLow, hashHigh;
    multiHash3D(i + seed, ip1 + seed, hashLow, hashHigh);
    
    vec3 u = noiseInterpolate(f);
    vec4 r = mix(hashLow, hashHigh, u.z);
    r = mix(r.xyxz, r.zwyw, u.yyxx);
    return (r.x + (r.y - r.x) * u.x) * 2.0 - 1.0;
}

// 3D Value noise with height and derivatives that is tileable on the XY axis.
// @param scale Number of tiles, must be an integer for tileable results, range: [2, inf]
// @param time The height phase for the noise value, range: [0, inf], default: 0.0
// @param seed Seed to randomize result, range: [0, inf]
// @return x = value of the noise, yz = derivative of the noise, w = derivative of the time, range: [-1, 1]
vec4 noised3d(vec2 pos, vec2 scale, float time, float seed) 
{
    // based on Analytical Noise Derivatives by Brian Sharpe
    // classic value noise with 3D
    pos *= scale;
    vec3 i = floor(vec3(pos, time));
    vec3 ip1 = i + vec3(1.0);
    vec3 f = vec3(pos, time) - i;
    
    vec4 mi = mod(vec4(i.xy, ip1.xy), scale.xyxy);
    i.xy = mi.xy;
    ip1.xy = mi.zw;

    vec4 hashLow, hashHigh;
    multiHash3D(i + seed, ip1 + seed, hashLow, hashHigh);

    vec3 u, du;
    noiseInterpolateDu(f, u, du);
    vec4 res0 = mix(hashLow, hashHigh, u.z);
    vec4 res1 = mix(res0.xyxz, res0.zwyw, u.yyxx);
    vec4 res2 = mix(vec4(hashLow.xy, hashHigh.xy), vec4(hashLow.zw, hashHigh.zw), u.y);
    vec2 res3 = mix(res2.xz, res2.yw, u.x);
    vec4 results = vec4(res1.x, 0.0, 0.0, 0.0) + (vec4(res1.yyw, res3.y) - vec4(res1.xxz, res3.x)) * vec4(u.x, du);
    return vec4(results.x * 2.0 - 1.0, results.yzw);
}

// 2D Variant of Value noise that produces ridge-like noise by using multiple noise values.
// @param scale Number of tiles, must be integer for tileable results, range: [2, inf]
// @param translate Translate factors for the value noise , range: [-inf, inf], default: {0.5, -0.25, 0.15}
// @param intensity The contrast for the noise, range: [0, 1], default: 0.75
// @param time The height phase for the noise value, range: [0, inf], default: 0.0
// @param seed Seed to randomize result, range: [0, inf]
// @return Value of the noise, range: [0, 1]
float gridNoise(vec2 pos, vec2 scale, vec3 translate, float intensity, float time, float seed)
{
    vec4 n; 
    n.x = noise(pos, scale, time, seed);
    n.y = noise(pos + translate.x, scale, time, seed);
    n.z = noise(pos + translate.y, scale, time, seed);
    n.w = noise(pos + translate.z, scale, time, seed);
    n.xy = n.xy * n.zw;
    
    float t = abs(n.x * n.y);
    return pow(t, mix(0.5, 0.1, intensity));
}

// 2D Variant of Value noise that produces ridge-like noise by using multiple noise values.
// @param scale Number of tiles, must be integer for tileable results, range: [2, inf]
// @param intensity The contrast for the noise, range: [0, 1], default: 0.75
// @param time The height phase for the noise value, range: [0, inf], default: 0.0
// @param seed Seed to randomize result, range: [0, inf]
// @return Value of the noise, range: [0, 1]
float gridNoise(vec2 pos, vec2 scale, float intensity, float time, float seed)
{
    vec3 translate = (hash3D(vec2(seed)) * 2.0 - 1.0) * scale.xyx;
    
    vec4 n; 
    n.x = noise(pos, scale, time, seed);
    n.y = noise(pos + translate.x, scale, time, seed);
    n.z = noise(pos + translate.y, scale, time, seed);
    n.w = noise(pos + translate.z, scale, time, seed);
    n.xy = n.xy * n.zw;
    
    float t = abs(n.x * n.y);
    return pow(t, mix(0.5, 0.1, intensity));
}

// 2D Variant of Value noise that produces dots with random size or luminance.
// @param scale Number of tiles, must be integer for tileable results, range: [2, inf]
// @param density The density of the dots distribution, range: [0, 1], default: 1.0
// @param size The radius of the dots, range: [0, 1], default: 0.5
// @param sizeVariance The variation for the size of the dots, range: [0, 1], default: 0.75
// @param roundness The roundness of the dots, if zero will result in square, range: [0, 1], default: 1.0
// @param seed Seed to randomize result, range: [0, inf]
// @return x = value of the noise, y = random luminance value, z = size of the dot, range: [0, 1]
vec3 dotsNoise(vec2 pos, vec2 scale, float density, float size, float sizeVariance, float roundness, float seed) 
{
    pos *= scale;
    vec4 i = floor(pos).xyxy + vec2(0.0, 1.0).xxyy;
    vec2 f = pos - i.xy;
    i = mod(i, scale.xyxy);
    
    vec4 hash = hash4d(i + seed);
    if (hash.w > density)
        return vec3(0.0);

    float radius = clamp(size + (hash.z * 2.0 - 1.0) * sizeVariance * 0.5, 0.0, 1.0);
    float value = radius / size;  
    radius = 2.0 / radius;
    f = f * radius - (radius - 1.0);
    f += hash.xy * (radius - 2.0);
    f = pow(abs(f), vec2((mix(20.0, 1.0, sqrt(roundness)))));

    float u = 1.0 - min(dot(f, f), 1.0);
    return vec3(clamp(u * u * u * value, 0.0, 1.0), hash.w, hash.z);
}

float randomLinesNoise(vec2 pos, const in vec2 scale, const in float count, const in float strength, float phase, const in bool tileable) 
{
    // tile on both axis
    vec2 p = pos + vec2(0.0, phase);
    float offset = tileable ? noise(fract(p), scale) : noise(p, scale * 8.0);
    return count * (strength * offset + pos.y);
}
vec3 randomLines(vec2 pos, vec2 scale, float count, float width, float jitter, vec2 smoothness, float phase, float seed, float luminanceVariation, bool tileable)
{
    float strength = jitter * 1.25;
    scale = tileable ? scale : scale * 8.0;

    float v = randomLinesNoise(pos, scale, count, strength, phase, tileable);
    // compute gradient
    vec3 offsets = vec3(1.0, 0.0, -1.0) / iResolution.x*2.0;
    vec4 nn = pos.xyxy + offsets.xyzy;
    float dx = randomLinesNoise(nn.xy, scale, count, strength, phase, tileable) - randomLinesNoise(nn.zw, scale, count, strength, phase, tileable);
    nn = pos.xyxy + offsets.yxyz;
    float dy = randomLinesNoise(nn.xy, scale, count, strength, phase, tileable) - randomLinesNoise(nn.zw, scale, count, strength, phase, tileable);
   // dx += dFdx(v);
    //dy += dFdy(v);
    //dx *=0.5;
    //dy *=0.5;
    vec2 grad = vec2(dx, dy) / (2.0 * offsets.x);
    
    float w = fract(v) / length(grad);
    float aa = fwidth(w);
    width *= 0.1;
    smoothness *= width;
    float d = smoothstep(0.0, smoothness.x +0.*aa, w) - smoothstep(max(width - smoothness.y, 0.0), width, w);
    return vec3(fract(v/count));//d * (1.0 - hash3d(mod(floor(v) + seed, count)) * luminanceVariation);
}
