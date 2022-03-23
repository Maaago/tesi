//
//  Clipper.hpp
//  clipper - VST3
//
//  Created by Francesco Magoga
//

#ifndef Clipper_hpp
#define Clipper_hpp

#define MAX_L_VALUE 50.0

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
		Clipper();
		~Clipper();
	
		void setL(unsigned int L);
		void setSampleRate(unsigned int sampleRate);
		void useNewtonRaphson(bool newtonRaphson);

		void process(float *buffer, size_t size);
		
	private:
		Diode diodeA;
		Diode diodeB;
		
		float Rin, C, T, lastFPOutput, h;
	
		float capacitorVoltage(float vin);
		float fixedPoint(float lastFPOutput, float vin);
		float jacobian(float vb, float vin);
		float discretized(float vb, float vin, float oldVb);
		float summation(float vb, float vin);
	
		unsigned int L, sampleRate;
	
		float inputGain;
	
		bool newtonRaphson;
};

#endif /* Clipper_hpp */
