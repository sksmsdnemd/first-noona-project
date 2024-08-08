package com.bridgetec.common.osu.veloce;


public interface Header {
	
	@Override
	public String toString();
	
	public Header clone();
	
	public byte[] toByte();
	
	public byte[] toByte(int byteOrder);
	
	public byte[] toByte(int byteOrder, byte[] buffer);
	
	public byte[] toByte(int byteOrder, byte[] buffer, int offset);
	
	public int getHeaderLen();
	
	public void toObject(byte[] data);
	
	public void toObject(int byteOrder, byte[] data);

	public int getLength();
}
