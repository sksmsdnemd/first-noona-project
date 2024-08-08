package com.bridgetec.argo.common.util;

public class LicenseDecrypt {
   public native String decrypt(String jstr);
      static {
         System.loadLibrary("bcl");
      }

      public static String main(String licenseTxt) {
//      	String licenseTxt = "QQESMBdC33J5SY6BHNtiwgYjGOVpMnWDmLkJfZGl68C/KlXejq2HHrQzzYw+y2+YKceFEsBFu42BxuE49ox+I+C8OAsN2i5qpWbBaHsMYLXcBXKGPDVLAdkxvEu94envQA361wllA9BE+4lmvW/LXWxVQBE=";
//        licenseTxt = "0S8RHMasYYPGHINpFBv7XvuNzVdr7R+7iKqDPGbY5799HcM44c7mLdZV6doQeNum4NLLLOx9orhD4uOBHmT/9CRWpb//8V0jB1yty+re+Ox1Cszg5taVtTNSnYndGxJe+Q2zMXEmwCnQckMHRe6zYPWm8ChTgQOrHs5m9kuufWkxex2BJYBIu+fAdKEHO2YmvbpegVs6ZaJoavr1gOkmksZI5wK02ERmeS7WG20dlDx7M/8gClv6XP1Q9LVYKowg1qdU5j3mV1uMXqDud208YNNXrfe8EI4VkJuSsC8WcOPIc35TUMrDoIFeQlpHcZVBTPbId+jtyoVTzXq5bSEq4wXOCNQ3Iri3jVpdRsmyAbe43NLTB9K7iEvYZQlUwbOn08GP5bXlaHiQR6zd+5f30o8nb+HIZPbyojcq9baDQ4RZM30ZoOZIjN7Z7AduVUlQT/hDGW03M/dnjrPUaKUggMnZMKDcPxeR5+DngSBJkNRJvQPQC2V5oDleh7GwabAebZ4XD3Df8p/WNcZYpKWO5U6RSIg68xdcXOv3fIZ2KXruUMHbB7CyuKVqiO1cBpg+FIoHKfcJE/GZHA2U+XhywoPCUotyUdJR40iiOathoxJy2e/Nd220/OapWmKs1hoZKUywW1iJV/V0COJTZeN/cGrTDmk=";
        String res = new LicenseDecrypt().decrypt(licenseTxt);
        System.out.println("JAVA print : " + res);
        
        return res;
      }
}