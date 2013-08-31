/**
 * Created By: Alex Vallejo
 * Date: 8/30/13
 * Project: lab1
 * Notes: This is a base conversion utility.
 */

import java.lang.Math;

public class BaseConverter {

    public static void main(String[] args){

        char[] num;
        int numLength;
        int base;
        int dec = 0;
        String bin, hex;

        //If invalid usage, print instructions and exit.
        if (args.length != 2){
            System.out.println("Usage: java BaseConverter [BIN,HEX,DEC] [BASE]");
            System.out.println("Example: java BaseConverter 1001011010, 16");
            System.exit(1);
        }

        //If the number is too long, print instructions and exit
        if (args[0].length() > 16){
            System.out.println("Maximum input length is 16.");
            System.exit(1);
        }

        numLength = args[0].length();
        base = Integer.parseInt(args[1]);

        //If the base is incorrect
        if (base != 2 && base != 10 && base != 16){
            System.out.println("You may only enter bases of 2, 10 & 16.");
            System.exit(1);
        }

        //If the number is input as a decimal no initial conversion is necessary
        if (base == 10){
            dec = Integer.parseInt(args[0]);
        }

        //If the number is a bin or hex, store it's characters in an array
        else{
            num = new char[16];
            for (int i = 0; i < numLength; i++){
                num[i] = args[0].charAt(i);
            }

            dec = toDec(num, numLength, base);
        }


        System.out.println("Dec: " + dec);
        System.out.println("Bin: " + toBin(dec));
        System.out.println("Hex: " + toHex(dec));
        System.out.println("Unary: " + toUni(dec));


    }//end main

    public static int toDec(char[] num, int numLength, int base){
        int dec = 0;

        //If binary
        if (base == 2){
            int position = 0;
            for (int power = numLength - 1; power >= 0; power--){
                dec += (num[position] - 48) * (Math.pow(base, power));
                position++;
            }
            return dec;
        }

        //Base 16
        //TODO implement for uppercase letters also
        else{
            for (int i = 0; i < numLength - 1; i++){

                //If a character in the initial number is higher is the ASCII
                //character set than 9 (which is 57) then it is a letter representing
                //10-15 in hex
                if (num[i] > 57){
                    dec += (num[i] - 87) * 16^i;
                }

                //Its just a normal base 10 number
                else
                    dec += (num[i] - 48) * 16^i;
            }

            return dec;
        }
    }

    public static String toUni(int dec){
        String number = "";

        for (int i = dec; i > 0; i--){
            number += '|';
        }

        return number;
    }

    public static String toHex(int dec){
        return "";
    }

    public static String toBin(int dec){

        return "";
    }
}//end BaseConverter