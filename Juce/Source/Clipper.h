//
//  Clipper.hpp
//  clipper - VST3
//
//  Created by Francesco Magoga
//

#ifndef Clipper_hpp
#define Clipper_hpp

#include <vector>

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

		void process(float *buffer, size_t size);
		
	private:
		Diode diodeA;
		Diode diodeB;
		
		float Rin, C, T, lastFPOutput;
	
		float capacitorVoltage(float vin);
		float fixedPoint(float lastFPOutput, float vin);
		float jacobian(float vb, float vin);
		float discretized(float j, float oldVb);
		float summation(float j);
	
		int L;
	
		float arcsinh(float x);
};

#endif /* Clipper_hpp */
