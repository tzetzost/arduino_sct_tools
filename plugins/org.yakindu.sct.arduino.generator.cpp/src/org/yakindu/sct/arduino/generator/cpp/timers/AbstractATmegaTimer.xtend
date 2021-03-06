/**
 * Copyright (c) 2016 by Lothar Wendehals.
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.yakindu.sct.arduino.generator.cpp.timers

import com.google.inject.Inject
import org.yakindu.sct.arduino.generator.cpp.GenmodelEntries
import org.yakindu.sct.arduino.generator.cpp.Naming
import org.yakindu.sct.model.sexec.ExecutionFlow
import org.yakindu.sct.model.sgen.GeneratorEntry

abstract class AbstractATmegaTimer extends AbstractTimer {

	@Inject extension Naming
	@Inject extension GenmodelEntries

	override generateTimer(GeneratorEntry it, ExecutionFlow flow) '''
		«licenseText»
		
		#include "«timerName.h»"
		
		«variableDeclarations(flow)»
		
		«ISR»
		
		«constructor»
		
		«start»
		
		«init»
		
		«setTimer»
		
		«unsetTimer»
		
		«runCycle»
		
		«raiseTimeEvents»
		
		«sleep»
		
		«cancel»
	'''

	override protected headerIncludes(GeneratorEntry it, ExecutionFlow flow) '''
		#include <avr/sleep.h>
		«super.headerIncludes(it, flow)»
	'''

	override protected privateHeaderPart(GeneratorEntry it) '''
		«super.privateHeaderPart(it)»
		
		void sleep();
	'''

	protected def CharSequence ISR(GeneratorEntry it)

	override protected runCycleBody(GeneratorEntry it) '''
		if (runCycleFlag) {
			«super.runCycleBody(it)»
			runCycleFlag = false;
		}
		sleep();
	'''

	protected def sleep(GeneratorEntry it) '''
		void «timerName»::sleep() {
			«sleepBody»
		}
	'''

	protected def sleepBody(GeneratorEntry it) '''
		hardware->prepareSleepMode();
		
		set_sleep_mode(SLEEP_MODE_IDLE);
		noInterrupts();
		sleep_enable();
		interrupts();
		sleep_cpu();
		sleep_disable();
	'''

	protected def int maxPeriod()

	protected def useOverflows(GeneratorEntry entry) {
		entry.cyclePeriod > maxPeriod;
	}

}
