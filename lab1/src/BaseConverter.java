/**
 * Created By: Alex Vallejo
 * Date: 8/30/13
 * Project: lab1
 * Notes: This is a base conversion utility.
 */

import java.lang.Math;
import java.util.Stack;

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
        System.out.println("Bin: " + decToBase(dec, 2));
        System.out.println("Hex: " + decToBase(dec, 16));
        System.out.println("Unary: " + decToBase(dec, 1));


    }//end main

    /**
     * Convert any String representation of a number in base 2,
     * 10 or 16 to its decimal representation as an int
     * @param num char array of the input number
     * @param numLength the length of the String representation of the input
     *                  number
     * @param base the base the input number is currently in
     * @return an int value of the input number
     */
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
            int position = 0;
            for (int power = numLength - 1; power >= 0; power--){

                //If a character in the initial number is higher in the ASCII
                //character set than 9 (which is 57) then it is a letter
                // representing 10-15 in hex
                if (num[position] > 57){
                    dec += (num[position] - 87) * Math.pow(base, power);
                }

                //Its just a normal base 10 number
                else
                    dec += (num[position] - 48) * Math.pow(base, power);

                position++;
            }

            return dec;
        }
    }

    /**
     * Convert and integer to any base up to base 36
     * @param dec the integer to be converted
     * @param base  the base to be converted to
     * @return the string representation of the converted value
     */
    public static String decToBase(int dec, int base){

        //The algorithm used here produces the values in reverse order so use
        // a stack to reverse the revere order yielding the proper order
        Stack<Character> reversedNumber = new Stack<Character>();
        String number = "";

        if (base == 1){
            for (int i = dec; i > 0; i--){
                number += '|';
            }

            return number;
        }

        while (dec/base != 0){
            reversedNumber.push(intToHex(dec % base));
            dec /= base;
        }

        //Add the final remainder to the hex value
        reversedNumber.push(intToHex(dec));

        while (!reversedNumber.isEmpty())
            number += reversedNumber.pop();

        if (base == 2){
            String padding = "";

            for (int i = number.length(); i < 16; i++)
                padding += '0';

            number = padding + number;
        }

        if (base == 16){
            String padding = "";

            for (int i = number.length(); i < 4; i++)
                padding += '0';

            number = padding + number;
        }

        return number;
    }

    /**
     * Returns the ASCII/UTF-8 character value for the given integer
     * Will work for any base up to base 36.
     * @param num the integer to be converted
     * @return the character representation of the input integer
     */
    public static char intToHex(int num){
        //TODO implement for uppercase letters also

        if (num < 10)
            return (char)(num + 48);
        else
            return (char)(num + 87);
    }
}//end BaseConverter