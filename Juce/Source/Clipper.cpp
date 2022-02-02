//
//  Clipper.cpp
//  clipper - VST3
//
//  Created by Francesco Magoga on 01/02/2022.
//

#include "Clipper.hpp"

#include <cmath>

#include <unistd.h>

Clipper::Clipper(int sampleRate)
{
	diodeA.alpha = 1/(2*23e-3);         //23mV
	diodeA.beta = 2.52e-9;              //2.52nA
	diodeB.alpha = 1/(2*23e-3);         //23mV
	diodeB.beta = 2.52e-9;              //2.52nA

	Rin = 1e3;                          //1kOhm
	C = 100e-9;                         //100nF
	
	T = 1.0f/sampleRate;
	
	unlink("/Users/francesco/Desktop/log.txt");
	
	//this->log = std::ofstream("/Users/francesco/Desktop/log.txt", std::ios::app);
}

Clipper::~Clipper()
{
	
}

void Clipper::process(float *buffer, size_t size)
{
	for(int sample=0;sample<size;sample++)
	{
		float vb = 0;
		if(sample > 0)
			vb = buffer[sample-1];
		
		buffer[sample] = fixed_point(vb, buffer[sample]);
		
		buffer[sample] = T*asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*buffer[sample]))/diodeA.alpha+buffer[sample];
	}
}


float Clipper::fixed_point(float lastIterationOutput, float vin)
{
	float threshold = 1e-4;
	
	double vb = lastIterationOutput;
	double oldVb = vb+1;
	
	int iteration = 0;
	while(abs(vb-oldVb) > threshold && iteration < 250)
	{
		oldVb = vb;
		
		vb = vb-summation(vb, vin)*(vb-discretized(vb, lastIterationOutput, vin));
		
		iteration++;
	}
	
	return vb;
}

double Clipper::discretized(double vb, double oldVb, double vin)
{
	//part1
	double squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+pow(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb), 2));
	double denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
	double part1 = squareRoot/denominator;
	
	//part2
	double voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
	double diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
	double part2 = voltagesPart-diodePart;

	//result
	vb = T/C * part1 * part2 + oldVb;
	
	return vb;
}

double Clipper::summation(double vb, double vin)
{
	int L = 1;
	
	double s = 1;
	for(int l=1;l<L;l++)
		s = s+pow(jacobian(vb, vin), l);
	return s;
}

double Clipper::jacobian(double vb, double vin)
{
	//part1
	double squareRoot = diodeA.alpha*diodeA.beta*sqrt(1+pow(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb), 2));
	double denominator = diodeB.alpha*diodeB.beta*cosh(diodeB.alpha*vb)+squareRoot;
	double part1 = squareRoot/denominator;
	
	//part2
	double voltagesPart = (vin-asinh(diodeB.beta/diodeA.beta*sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
	double diodePart = 2*diodeB.beta*sinh(diodeB.alpha*vb);
	double part2 = voltagesPart-diodePart;
	
	//result
	double j = C * part1 * part2;
	
	return j;
}
