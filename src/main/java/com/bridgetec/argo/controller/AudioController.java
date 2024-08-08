package com.bridgetec.argo.controller;

import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;


//@RequestMapping("/speech.do")
public class AudioController {

    private static final Logger logger = LoggerFactory.getLogger(AudioController.class);
    private final Path audioLocation = Paths.get("audio");

    @RequestMapping(value = "/speech.do", method = RequestMethod.POST)
    public ResponseEntity<Resource> getAudio(@RequestBody Map<String, String> request) {
        String word = request.get("word");
        try {
        	System.out.println("스피치로 들어왔어요!!!");
        	
            Path file = audioLocation.resolve(word + ".mp3").normalize();
            logger.info("Requested file path: {}", file.toUri());

            if (!Files.exists(file) || !Files.isReadable(file)) {
                logger.error("File not found or not readable: {}", file);
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
            
            Resource resource = new UrlResource(file.toUri());
            if (resource.exists() && resource.isReadable()) {
                HttpHeaders headers = new HttpHeaders();
//                headers.add(HttpHeaders.CONTENT_TYPE, "audio/mpeg");
                headers.add("Content-Type", "audio/mpeg");
                return new ResponseEntity<>(resource, headers, HttpStatus.OK);
            } else {
                logger.error("Resource not found or not readable: {}", resource);
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (MalformedURLException e) {
            logger.error("MalformedURLException: ", e);
            return new ResponseEntity<>(HttpStatus.BAD_REQUEST);
        } catch (Exception e) {
            logger.error("Exception: ", e);
            return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}