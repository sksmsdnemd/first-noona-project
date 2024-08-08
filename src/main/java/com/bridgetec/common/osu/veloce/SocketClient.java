package com.bridgetec.common.osu.veloce;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.InvocationTargetException;
import java.math.BigDecimal;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

//import com.bt.veloce.common.db.DBKindInfo;
import com.bridgetec.common.osu.veloce.Destination;
import com.bridgetec.common.osu.veloce.Message;

public abstract class SocketClient {

	public static final int BYTE_ORDER_BIG = 1;
	public static final int BYTE_ORDER_LITTLE = 2;
	public static int SOCKET_TIME_OUT = 5000;

	private int byteOrder;

	public abstract Message send(int byteOrder, Message msg)
			throws IOException, IllegalArgumentException, SecurityException,
			InstantiationException, IllegalAccessException,
			InvocationTargetException, NoSuchMethodException;

	public abstract Message send(Message msg) throws IOException,
			IllegalArgumentException, InstantiationException,
			IllegalAccessException, InvocationTargetException,
			SecurityException, NoSuchMethodException;

	public abstract Message[] send(int byteOrder, Message[] msgList)
			throws IOException, SecurityException, IllegalArgumentException,
			NoSuchFieldException, NoSuchMethodException,
			InstantiationException, IllegalAccessException,
			InvocationTargetException;

	public abstract Message[] send(Message[] msgList) throws IOException,
			SecurityException, NoSuchFieldException, NoSuchMethodException,
			IllegalArgumentException, InstantiationException,
			IllegalAccessException, InvocationTargetException;

	protected Socket getSocket(String ip, int port, int timeout) throws UnknownHostException, IOException {
		Socket s = new Socket(ip, port);
		s.setSoTimeout(timeout);
		return s;
	}

	protected Socket getSocket(String ip, int port) throws UnknownHostException, IOException {
		return getSocket(ip, port, SOCKET_TIME_OUT);
	}

	protected int getByteOrder() {
		return byteOrder;
	}

	protected void setByteOrder(int byteOrder) {
		this.byteOrder = byteOrder;
	}

	protected void send(OutputStream out, byte[] data, int offset, int len) throws IOException {
		out.write(data, offset, len);
		out.flush();
	}

	protected byte[] receive(InputStream in, int length) throws IOException {
		return TcpUtil.read_data(in, length);
	}

	public Map<String, List<Destination>> getDestinationListSet(
			Map<String, Destination> processNameListSet,
			List<Map<String, ?>> srcProcessList) {
		Iterator<String> iter = processNameListSet.keySet().iterator();
		Map<String, List<Destination>> result = new HashMap<String, List<Destination>>();
		String[] processNameList = new String[processNameListSet.size()];
		int[] defaultPortList = new int[processNameListSet.size()];
		int idx = 0;
		while (iter.hasNext()) {
			processNameList[idx] = iter.next();
			defaultPortList[idx] = processNameListSet
					.get(processNameList[idx]).getPort();
			result.put(processNameList[idx], new ArrayList<Destination>());
			idx++;
		}
		
		
			//System.out.println("===================================> srcProcessList.size() : " + srcProcessList.size());////////////////////////
			for (int i = 0; i < srcProcessList.size(); i++) {
				Map<String, ?> info = srcProcessList.get(i);
				String processNm = (String) info.get("code_name");
				//System.out.println("===================================> processNm : " + processNm);//////////////////////////////
				int portIdx = ((Integer) info.get("port_idx")).intValue();
				//System.out.println("===================================> portIdx : " + portIdx);//////////////////////////////
				for (int j = 0; j < processNameList.length; j++) {
					if (processNm.equals(processNameList[j])) {
						Destination dest = new Destination(
							(String) info.get("system_ip"), 
							defaultPortList[j] + portIdx,
							(Integer) info.get("system_id"), 
							(Integer) info.get("process_id")
						);
						result.get(processNm).add(dest);
					}
				}
			}
		
		//수정부분 끝

		return result;
	}
}
