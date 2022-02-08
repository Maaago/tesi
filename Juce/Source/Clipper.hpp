//
//  Clipper.hpp
//  clipper - VST3
//
//  Created by Francesco Magoga on 01/02/2022.
//

#ifndef Clipper_hpp
#define Clipper_hpp

#include <vector>
#include <fstream>

class Diode
{
	public:
		float alpha;
		float beta;
};

class Clipper
{
	public:
		Clipper(int sampleRate);
		~Clipper();
	
		void setL(int L);

		void process(float *buffer, size_t size, float lastSample);
		
	private:
		Diode diodeA;
		Diode diodeB;
		
		float Rin, C, T;
	
		float fixed_point(float lastIterationOutput, float vin);
		float discretized(float vb, float oldVb, float vin);
		float summation(float vb, float vin);
		float jacobian(float vb, float vin);
	
		std::ofstream log;
	
		int L;
	
	float arcsinh(float x);
};

#endif /* Clipper_hpp */
