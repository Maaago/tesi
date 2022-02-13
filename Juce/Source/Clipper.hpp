//
//  Clipper.hpp
//  clipper - VST3
//
//  Created by Francesco Magoga
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
	
		float capacitorVoltage(float lastIterationOutput, float vin);
		float fixedPoint(float lastIterationOutput, float vin);
		float common(float vb, float vin);
		float discretized(float oldVb, float c);
		float summation(float c);
		float jacobian(float c);
	
		std::ofstream log;
	
		int L;
	
	float arcsinh(float x);
};

#endif /* Clipper_hpp */
