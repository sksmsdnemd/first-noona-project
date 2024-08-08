package com.bridgetec.common.osu.veloce;

public class TIDSeqManager {

	private static TIDSeqManager instance = new TIDSeqManager();
	private int seq = 0;


	/********************************************************************************
	 * Class initialize
	 ********************************************************************************/
	private TIDSeqManager(){}

	
	/********************************************************************************
	 * Specialization methods
	 ********************************************************************************/
	public static TIDSeqManager getInstance(){
		return TIDSeqManager.instance;
	}

	
	/********************************************************************************
	 * Implements ocp.ocps.common.utils.sequence.SeqManager
	 ********************************************************************************/
	public synchronized int getNextSeq(){
		if( seq >= Integer.MAX_VALUE){
			seq = 0;
		}
		seq += 1;
		
		return seq;
	}
	
	public synchronized int getCurrentSeq(){
		return seq;
	}
}
