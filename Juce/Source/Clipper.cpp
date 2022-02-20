//
//  Clipper.cpp
//  clipper - VST3
//
//  Created by Francesco Magoga
//

#include "Clipper.h"

#include <cmath>

#include <unistd.h>

#include <juce_dsp/maths/juce_FastMathApproximations.h>

#define THRESHOLD 1e-4				//in Volts
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
	
	L = 0;								//Valore iniziale di L
	
	lastFPOutput = 0;
}

Clipper::~Clipper()
{
	
}

void Clipper::setL(int L)
{
	//this->L = L;
}

void Clipper::process(float *buffer, size_t size)
{
	for(int sample=0;sample<size;sample++)
		buffer[sample] = capacitorVoltage(buffer[sample]);
}

float Clipper::capacitorVoltage(float vin)
{
	float vb = fixedPoint(lastFPOutput, vin);
	float va = std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb))/diodeA.alpha;
	
	lastFPOutput = vb;
	
	return va+vb;
}

float Clipper::fixedPoint(float lastFPOutput, float vin)
{
	float vb = lastFPOutput;
	float oldVb = vb+1;
	
	unsigned int iteration = 0;
	while(std::abs(vb-oldVb) > THRESHOLD && iteration < MAX_ITERATIONS)
	{
		oldVb = vb;
		
		float j = jacobian(vb, vin);
		vb = vb-summation(j)*(vb-discretized(j, lastFPOutput));
		
		iteration++;
	}
	
	return vb;
}

float Clipper::discretized(float j, float oldVb)
{
	return T * j + oldVb;
}

float Clipper::jacobian(float vb, float vin)
{
	//part1
	float arg = diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb);
	float squareRoot = diodeA.alpha*diodeA.beta*std::sqrt(1+std::pow(arg, 2));
	float denominator = diodeB.alpha*diodeB.beta*juce_math::cosh(diodeB.alpha*vb)+squareRoot;
	float part1 = squareRoot/denominator;

	//part2
	float va = std::asinh(diodeB.beta/diodeA.beta*juce_math::sinh(diodeB.alpha*vb))/diodeA.alpha;
	float voltagesPart = (vin-va-vb)/Rin;
	float diodePart = 2*diodeB.beta*juce_math::sinh(diodeB.alpha*vb);
	float part2 = voltagesPart-diodePart;

	return part1 * part2 / C;
}

float Clipper::summation(float j)
{
	//Invece che calcolare la potenza ad ogni iterazione del ciclo viene moltiplicato il valore dell'iterazione precedente per j
	
	float sum = 1;
	float power = 1;

	for(int l=1;l<=L;l++)
	{
		power *= j;
		
		sum += power;
	}
	
	return sum;
}
