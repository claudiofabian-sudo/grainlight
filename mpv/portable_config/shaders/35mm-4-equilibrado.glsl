// ============================================================
//  35MM EMULATOR v2 — PRESET 4: "EQUILIBRADO"
//  Grano fino tipo Kodak Vision3, gate weave casi imperceptible,
//  contraste/saturación apenas realzados. Sin polvo.
//  Para cuando quieres textura viva sin que se note el truco.
//
//  Grano v2: hash entero PCG + ruido multi-octava. Organico,
//  isotropico, sin bandas ni patrones repetidos.
// ============================================================

//!HOOK MAIN
//!BIND HOOKED
//!DESC 35mm-4 gate weave

#define WEAVE_X  0.00075   // deriva horizontal (fraccion de la altura)
#define WEAVE_Y  0.00100   // deriva vertical
#define JITTER   0.00032   // temblor por fotograma
#define FLICKER  0.0045    // parpadeo de brillo del proyector

float h1(float n) { return fract(sin(n) * 43758.5453123); }

vec4 hook() {
    float t = float(frame);
    float px = HOOKED_size.y;
    vec2 drift = vec2(
        sin(t * 0.113) * 0.55 + sin(t * 0.041 + 1.3) * 0.45,
        sin(t * 0.097 + 0.7) * 0.50 + sin(t * 0.033 + 2.1) * 0.50);
    vec2 jit = vec2(h1(t * 1.371) - 0.5, h1(t * 2.113) - 0.5) * 2.0;
    vec2 off_px = (drift * vec2(WEAVE_X, WEAVE_Y) + jit * JITTER) * px;
    vec4 c = HOOKED_texOff(off_px);
    float fl = 1.0 + (h1(t * 0.719) - 0.5) * 2.0 * FLICKER
                   + sin(t * 0.523) * FLICKER * 0.5;
    c.rgb *= fl;
    return c;
}

//!HOOK MAIN
//!BIND HOOKED
//!DESC 35mm-4 grade (contraste/saturacion/vineta)

#define CONTRAST 0.22
#define SATUR    1.13
#define WARMTH   0.045
#define FADE     0.012
#define VIGNETTE 0.15
#define HALATION 0.12
#define HAL_THR  0.70

vec4 hook() {
    vec2 uv = HOOKED_pos;
    vec4 col = HOOKED_tex(uv);
    vec3 c = col.rgb;

    if (HALATION > 0.0) {
        vec3 blur = vec3(0.0);
        float r = HOOKED_size.y * 0.004;
        blur += HOOKED_texOff(vec2( 1.0, 0.0) * r).rgb;
        blur += HOOKED_texOff(vec2(-1.0, 0.0) * r).rgb;
        blur += HOOKED_texOff(vec2( 0.0, 1.0) * r).rgb;
        blur += HOOKED_texOff(vec2( 0.0,-1.0) * r).rgb;
        blur += HOOKED_texOff(vec2( 0.7, 0.7) * r).rgb;
        blur += HOOKED_texOff(vec2(-0.7, 0.7) * r).rgb;
        blur += HOOKED_texOff(vec2( 0.7,-0.7) * r).rgb;
        blur += HOOKED_texOff(vec2(-0.7,-0.7) * r).rgb;
        blur /= 8.0;
        vec3 hal = max(blur - vec3(HAL_THR), vec3(0.0));
        c += hal * vec3(1.0, 0.30, 0.12) * HALATION;
    }

    // curva S de contraste (respuesta de print fotoquimico)
    vec3 s = c * c * (3.0 - 2.0 * c);
    c = mix(c, s, CONTRAST);

    // desgaste de copia: levanta negros / baja blancos
    c = c * (1.0 - FADE) + vec3(FADE * 0.45);

    // calidez de lampara de xenon/tungsteno
    c *= vec3(1.0 + WARMTH * 0.6, 1.0 + WARMTH * 0.15, 1.0 - WARMTH * 0.7);

    // saturacion
    float l = dot(c, vec3(0.2126, 0.7152, 0.0722));
    c = mix(vec3(l), c, SATUR);

    // vineta de lente de proyeccion
    vec2 d = (uv - 0.5) * vec2(1.1, 1.0);
    float v = 1.0 - VIGNETTE * smoothstep(0.35, 1.05, length(d) * 1.5);
    c *= v;

    return vec4(clamp(c, 0.0, 1.0), col.a);
}

//!HOOK OUTPUT
//!BIND HOOKED
//!DESC 35mm-4 grano organico v2

#define GRAIN       0.078   // intensidad del grano
#define GRAIN_SIZE  2.9     // tamano del grano en px (a 4K)
#define CHROMA_GR   0.32    // decorrelacion de color del grano
#define DUST_PROB   0.15    // probabilidad de mota de polvo por fotograma
#define HAIR_PROB   0.35    // fraccion de motas que son pelusas alargadas
#define CUE_PERIOD  720.0   // quemadura cada 12 min (segundos; 0 = off)

// --- hash entero PCG: ruido blanco de alta calidad, sin patrones ---
uvec3 pcg3d(uvec3 v) {
    v = v * 1664525u + 1013904223u;
    v.x += v.y * v.z; v.y += v.z * v.x; v.z += v.x * v.y;
    v ^= v >> 16u;
    v.x += v.y * v.z; v.y += v.z * v.x; v.z += v.x * v.y;
    return v;
}
float hashf(ivec2 p, uint s) {
    return float(pcg3d(uvec3(uvec2(p + 32768), s)).x) * (1.0 / 4294967296.0);
}
vec3 rnd3(uint a, uint b) {
    uvec3 r = pcg3d(uvec3(a, b, 0x9E3779B9u));
    return vec3(r) * (1.0 / 4294967296.0);
}
// ruido de valor interpolado sobre celdas del tamano del grano
float gnoise(vec2 p, uint s) {
    vec2 i = floor(p), f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hashf(ivec2(i),               s);
    float b = hashf(ivec2(i) + ivec2(1, 0), s);
    float c = hashf(ivec2(i) + ivec2(0, 1), s);
    float d = hashf(ivec2(i) + ivec2(1, 1), s);
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}
// grano de emulsion: 3 octavas independientes + chispa fina.
// La suma de octavas aproxima una distribucion gaussiana (como
// la densidad de cristales de plata reales).
float grain_val(vec2 pix, float gs, uint s) {
    float g = 0.0;
    g += (gnoise(pix / gs,          s              ) - 0.5);
    g += (gnoise(pix / (gs * 0.53) + 61.7, s ^ 0x85EBCA6Bu) - 0.5) * 0.55;
    g += (gnoise(pix / (gs * 1.91) + 19.3, s ^ 0xC2B2AE35u) - 0.5) * 0.60;
    g += (hashf(ivec2(pix), s ^ 0xB5297A4Du) - 0.5) * 0.22;
    return g * 0.85;
}

vec4 hook() {
    vec4 col = HOOKED_tex(HOOKED_pos);
    uint s = uint(frame);
    vec2 pix = HOOKED_pos * HOOKED_size;
    float ar = HOOKED_size.x / HOOKED_size.y;

    // --- grano ---
    float gs = GRAIN_SIZE * max(HOOKED_size.y / 2160.0, 0.5);
    float g = grain_val(pix, gs, s);
    float l = dot(col.rgb, vec3(0.2126, 0.7152, 0.0722));
    // el grano vive en medios tonos, se esconde en negros y altas luces
    float resp = smoothstep(0.02, 0.20, l) * (1.0 - 0.65 * smoothstep(0.45, 1.0, l)) + 0.06;
    // grano de color: cada canal con semilla propia, muy sutil
    vec3 cg = vec3(
        gnoise(pix / gs + 7.1,  s ^ 0xA511E9B3u),
        gnoise(pix / gs + 3.7,  s ^ 0x63D83595u),
        gnoise(pix / gs + 11.3, s ^ 0x8C0DACF9u)) - 0.5;
    col.rgb += (vec3(g) + cg * CHROMA_GR) * GRAIN * resp;

    // --- polvo / pelusas (motas de 1-2 fotogramas) ---
    if (DUST_PROB > 0.0) {
        vec2 uv = HOOKED_pos;
        for (int i = 0; i < 3; i++) {
            uint ui = uint(i);
            vec3 r0 = rnd3(s, ui * 3u + 1u);
            if (r0.x < DUST_PROB) {
                vec3 r1 = rnd3(s, ui * 3u + 2u);
                vec3 r2 = rnd3(s, ui * 3u + 3u);
                vec2 pos = r0.yz;
                float sz = 0.0012 + 0.0028 * r1.x;
                float hair = step(1.0 - HAIR_PROB, r1.y);
                float ang = r1.z * 6.2831853;
                mat2 rot = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
                vec2 dd = rot * ((uv - pos) * vec2(ar, 1.0));
                dd.y *= mix(1.0, 6.0 + 5.0 * r2.y, hair);
                float dist = length(dd);
                float a = 1.0 - smoothstep(sz * 0.35, sz, dist);
                float shade = r2.x < 0.8 ? 0.03 : 0.92;
                col.rgb = mix(col.rgb, vec3(shade), a * (0.65 + 0.25 * r2.z));
            }
        }
    }

    // --- quemadura de cigarro: marca de cambio de rollo ---
    // Como en las salas reales: una marca de aviso y, 8 s despues,
    // la de cambio; cada una dura ~4 fotogramas, arriba a la derecha.
    if (CUE_PERIOD > 0.0) {
        float tsec = float(frame) / 23.976;
        float rem = CUE_PERIOD - mod(tsec, CUE_PERIOD);
        bool m2 = rem < 0.17;
        bool m1 = rem > 8.0 && rem < 8.17;
        if (m1 || m2) {
            uint burst = uint(tsec / CUE_PERIOD) * 2u + (m2 ? 1u : 0u);
            vec3 rb = rnd3(burst, 77u);
            vec2 uvq = HOOKED_pos;
            vec2 center = vec2(0.952 + 0.006 * (rb.x - 0.5),
                               0.072 + 0.010 * (rb.y - 0.5));
            vec2 dq = (uvq - center) * vec2(ar, 1.0);
            float rad = 0.021;
            // borde irregular, distinto en cada quemadura
            float irr = gnoise(dq / rad * 2.3 + vec2(rb.z * 90.0, rb.x * 70.0), burst) - 0.5;
            float r2 = rad * (1.0 + 0.22 * irr);
            float dl = length(dq);
            float core = 1.0 - smoothstep(r2 * 0.7, r2, dl);
            float ring = smoothstep(r2 * 0.65, r2, dl) * (1.0 - smoothstep(r2, r2 * 1.4, dl));
            col.rgb = mix(col.rgb, vec3(0.10, 0.06, 0.035), core * 0.92);
            col.rgb += vec3(0.45, 0.18, 0.05) * ring * 0.55;
        }
    }

    return col;
}
