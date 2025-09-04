float RandomFloat(float2 seed)
{
	//result will be between 0.00001 and 1.00001
	return frac(sin(dot(seed, float2(12.9898, 78.233))) * 43758.5453) + 0.00001;
}

void RandomNormal_float(float2 seed, float min, float max, out float3 normal)
{
	float u1 = RandomFloat(seed);
	float u2 = RandomFloat(seed + float2(132.54, 465.32));
	
    if (u1 > 1)
    {
        u1 = 1;
    }
	
    float r = sqrt(-2.0 * log(u1)) * 4.0;
	float theta = 2.0 * 3.14159 * u2;

	float x = r * cos(theta);
	float y = r * sin(theta);

	float2 n;
	n.x = x * (max - min) + min;
	n.y = y * (max - min) + min;

	normal = float3(n.x, n.y, 1);
}