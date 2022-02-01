//
//  Clipper.hpp
//  clipper - VST3
//
//  Created by Francesco Magoga on 01/02/2022.
//

#ifndef Clipper_hpp
#define Clipper_hpp

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
		
		void process(float *buffer, size_t size);
		
	private:
		Diode diodeA;
		Diode diodeB;
		
		double Rin, C, T;
	
		float fixed_point(float lastIterationOutput, float vin);
		double discretized(double vb, double oldVb, double vin);
		double summation(double vb, double vin);
		double jacobian(double vb, double vin);
	
		std::ofstream log;
};

#endif /* Clipper_hpp */
