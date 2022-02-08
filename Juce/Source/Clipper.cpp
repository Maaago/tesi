//
//  Clipper.cpp
//  clipper - VST3
//
//  Created by Francesco Magoga on 01/02/2022.
//

#include "Clipper.hpp"

#include <cmath>

#include <unistd.h>

#include <juce_dsp/maths/juce_FastMathApproximations.h>

#define INPUT_MULTIPLIER 0.95f
#define MAX_ITERATIONS 250

using juce_math = juce::dsp::FastMathApproximations;

Clipper::Clipper(int sampleRate)
{
	diodeA.alpha = 1/(2*23e-3);         //23mV
	diodeA.beta = 2.52e-9;              //2.52nA
	diodeB.alpha = 1/(2*23e-3);         //23mV
	diodeB.beta = 2.52e-9;              //2.52nA
	
	Rin = 1e3;                          //1kOhm
	C = 100e-9;                         //100nF
	
	T = 1.0f/sampleRate;
	
	L = 0;
	
	//unlink("/Users/francesco/Desktop/log.txt");
	
	//log = std::ofstream("/Users/francesco/Desktop/log.txt", std::ios::app);
}

Clipper::~Clipper()
{
	
}

void Clipper::setL(int L)
{
	this->L = L;
}

void Clipper::process(float *buffer, size_t size, float lastSample)
{
	for(int sample=0;sample<size;sample++)
	{
		float vb = lastSample;
		if(sample > 0)
			vb = buffer[sample-1];
		
		buffer[sample] = fixed_point(vb, buffer[sample]*INPUT_MULTIPLIER);
		
		buffer[sample] = T*std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*buffer[sample]))/diodeA.alpha+buffer[sample];
	}
}


float Clipper::fixed_point(float lastIterationOutput, float vin)
{
	float threshold = 1e-4;
	
	float vb = lastIterationOutput;
	float oldVb = vb+1;
	
	unsigned int iteration = 0;
	while(std::abs(vb-oldVb) > threshold && iteration < MAX_ITERATIONS)
	{
		oldVb = vb;
		
		vb = vb-summation(vb, vin)*(vb-discretized(vb, lastIterationOutput, vin));
		
		iteration++;
	}
	
	//log << iteration << std::endl;
	
	return vb;
}

float Clipper::discretized(float vb, float oldVb, float vin)
{
	//part1
	float squareRoot = diodeA.alpha*diodeA.beta*std::sqrt(1+std::pow(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb), 2));
	float denominator = diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb)+squareRoot;
	float part1 = squareRoot/denominator;

	//part2
	float voltagesPart = (vin-std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
	float diodePart = 2*diodeB.beta*juce_math::sinh(diodeB.alpha*vb);
	float part2 = voltagesPart-diodePart;

	//result
	vb = T/C * part1 * part2 + oldVb;
	
	return vb;
}

float Clipper::summation(float vb, float vin)
{
	float s = 1;
	for(int l=1;l<L;l++)
		s = s+std::pow(jacobian(vb, vin), l);
	return s;
}

float Clipper::jacobian(float vb, float vin)
{
	//part1
	float squareRoot = diodeA.alpha*diodeA.beta*std::sqrt(1+std::pow(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb), 2));
	float denominator = diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb)+squareRoot;
	float part1 = squareRoot/denominator;
	
	//part2
	float voltagesPart = (vin-std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb))/diodeA.alpha-vb)/Rin;
	float diodePart = 2*diodeB.beta*juce_math::sinh(diodeB.alpha*vb);
	float part2 = voltagesPart-diodePart;
	
	//result
	float j = C * part1 * part2;
	
	return j;
}
