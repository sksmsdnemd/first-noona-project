package com.bridgetec.common.osu.veloce;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.bridgetec.common.osu.veloce.Destination;
import com.bridgetec.common.osu.veloce.SocketClient;

public class OSUClient extends SocketClient {
	private final Logger logger = LoggerFactory.getLogger(OSUClient.class);

	@Override
	public Message send(int byteOrder, Message msg) throws IOException, IllegalArgumentException, SecurityException, InstantiationException, IllegalAccessException, InvocationTargetException, NoSuchMethodException {
		setByteOrder(byteOrder);
		return send(msg);
	}

	@Override
	public Message[] send(int byteOrder, Message[] msgList) throws IOException, SecurityException, IllegalArgumentException, NoSuchFieldException, NoSuchMethodException, InstantiationException, IllegalAccessException, InvocationTargetException{

		setByteOrder(byteOrder);
		return send(msgList);
	}

	@Override
	public Message send(Message msg) throws IOException, IllegalArgumentException, InstantiationException, IllegalAccessException, InvocationTargetException, SecurityException, NoSuchMethodException {
		BufferedInputStream in = null;
		BufferedOutputStream out = null;
		Socket s = null;

		Message ack = null;
		try {
			Destination dest = msg.getDestination();
			logger.debug("sysout Socket Server IP : "+dest.getIp()+", PORT : "+dest.getPort());
			logger.debug("Socket Server IP : "+dest.getIp()+", PORT : "+dest.getPort());
			
			s = getSocket(dest.getIp(), dest.getPort());
			in = new BufferedInputStream(s.getInputStream());
			out = new BufferedOutputStream(s.getOutputStream());

			logger.debug("SEND DATA={\n" + msg + "\n}");

			byte[] data = msg.toByte(getByteOrder());
			send(out, data, 0, data.length);

			Header 		ackHeader 		= new OSUHeader     (getByteOrder(), receive(in, OSUHeader.HEADER_LEN    ));
			Class ackBodyClass = msg.getAckBody();
			Body 		ackBody 		= null;
			
			if( ackBodyClass != null ){
			Class[] parameterTypes = { int.class, byte[].class };
			Object[] 	initargs 		= {getByteOrder(), receive(in, ackHeader.getLength())};
			Constructor c = null;
				
			c = ackBodyClass.getConstructor(parameterTypes);
			ackBody = (Body) c.newInstance(initargs);
			}

			ack = new Message(ackHeader, ackBody);

			logger.debug("RECEIVE DATA={\n" + ack + "\n}");

			if( in  != null ) in.close();
			if( out != null ) out.close();
			if( s   != null ) s.close();
		} catch (IOException e) {
			// TODO Auto-generated catch block
//			e.printStackTrace();
			logger.error("IOException : " + e.toString());
			throw e;
		} finally {
			if( in  != null ) in.close();
			if( out != null ) out.close();
			if( s   != null ) s.close();
		}
		return ack;
	}

	@Override
	public Message[] send(Message[] msgList) throws IOException, SecurityException, NoSuchFieldException, NoSuchMethodException, IllegalArgumentException, InstantiationException, IllegalAccessException, InvocationTargetException{
		BufferedInputStream in = null;
		BufferedOutputStream out = null;
		Socket s = null;

		// Message[] ack = new Message[msgList.length];
		List ackList = new ArrayList();
		for (int i = 0; i < msgList.length; i++) {
			Destination dest = msgList[i].getDestination();

			try {
				logger.debug("sysout Socket Server IP : "+dest.getIp()+", PORT : "+dest.getPort());
				logger.debug("Socket Server IP : "+dest.getIp()+", PORT : "+dest.getPort());
				
				s = new Socket(dest.getIp(), dest.getPort());
				in = new BufferedInputStream(s.getInputStream());
				out = new BufferedOutputStream(s.getOutputStream());

				logger.info("["+DateUtil.getTime("yyyy-MM-dd hh:mm:ss:S")+"]SEND DATA["+i+"]={\n"+msgList[i]+"\n}");
				

				byte[] data = msgList[i].toByte(getByteOrder());
				
				send(out, data, 0, data.length);
				
				Header 	ackHeader 	= new OSUHeader 	      (getByteOrder(), receive(in, OSUHeader.HEADER_LEN    ));
				
				Class ackBodyClass = msgList[i].getAckBody();
				AckBody 	ackBody 		= null;
				
				
				if( ackBodyClass != null ){
					Class[] parameterTypes = { int.class, byte[].class };
					Object[] 	initargs 		= {getByteOrder(), receive(in, ackHeader.getLength())};
					Constructor c = null;
						
					c = ackBodyClass.getConstructor(parameterTypes);
					ackBody = (AckBody) c.newInstance(initargs);
					if("0000".equals(ackBody.getResult())){
						ackBody.setMsg("OSU 전송 결과 : 성공 [IP : " + dest.getIp() + " , PORT : " + dest.getPort() + "]");
					}else{
						ackBody.setMsg("OSU 전송 결과 : 실패 [IP : " + dest.getIp() + " , PORT : " + dest.getPort() + "] \\nError Message : " + ackBody.getMsg());
					}
					
				}

				Message ack = new Message(ackHeader, ackBody);
				ackList.add(ack);

				logger.info("["+DateUtil.getTime("yyyy-MM-dd hh:mm:ss:S")+"]RECEIVE DATA[" + i + "]={\n" + ack + "\n}");

				if( in  != null ) in.close();
				if( out != null ) out.close();
				if( s   != null ) s.close();

			} catch (IOException e) {
				logger.error("IOException : "+e.toString());
				// TODO Auto-generated catch block
//				e.printStackTrace();
				Header 	ackHeader 	= new OSUHeader();
				
				Class 		ackBodyClass 	= msgList[i].getAckBody();
				AckBody 	ackBody			= (AckBody) ackBodyClass.newInstance();
				ackBody.setResult("9999");
				ackBody.setMsg("OSU 전송 결과 : 실패 [IP : "+dest.getIp()+" , PORT : "+dest.getPort() + "] \\nError Message : " +e.getMessage());

				//logger.error(e.getMessage());
				Message ack = new Message(ackHeader, ackBody, dest);
				
				ackList.add(ack);
				//throw e;
			} finally {
				if( in  != null ) in.close();
				if( out != null ) out.close();
				if( s   != null ) s.close();
			}
		}
		return (Message[]) ackList.toArray(new Message[ackList.size()]);
	}
}
