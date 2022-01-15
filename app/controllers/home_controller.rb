# app/controllers/home_controller.rb
class HomeController < ApplicationController
    
    @@message1 = {}

    def index

    end

    def calculate_syllables(word)
        word = word.downcase

        # exception_add are words that need extra syllables
        # exception_del are words that need less syllables
        
        exception_add = ['serious','crucial']
        exception_del = ['fortunately','unfortunately']
        
        co_one = ['cool','coach','coat','coal','count','coin','coarse','coup','coif','cook','coign','coiffe','coof','court']
        co_two = ['coapt','coed','coinci']
        
        pre_one = ['preach']
        

        syls = 0 # added syllable number
        disc = 0 # discarded syllable number

        #1) if letters < 3 : return 1
        return 1 if word.length <= 3

        #2) if doesn't end with "ted" or "tes" or "ses" or "ied" or "ies", discard "es" and "ed" at the end.
        # if it has only 1 vowel or 1 set of consecutive vowels, discard. (like "speed", "fled" etc.)
        if word[-2..-1] == "es" or word[-2..-1] == "ed"
            # doubleAndtripple_1 = len(re.findall(r'[eaoui][eaoui]', word))
            doubleAndtripple_1 = word.scan(/[eaoui][eaoui]/m).size
            doubleAndtripple_2 = word.scan(/[eaoui][^eaoui]/m).size
            if doubleAndtripple_1 > 1 or doubleAndtripple_2 > 1
                if word[-3..-1] == "ted" or word[-3..-1] == "tes" or word[-3..-1] == "ses" or word[-3..-1] == "ied" or word[-3..-1] == "ies"
                        pass
                else
                    disc += 1
                end
            end
        end

        #3) discard trailing "e", except where ending is "le"  
        le_except = ['whole','mobile','pole','male','female','hale','pale','tale','sale','aisle','whale','while']
        
        if word[-1] == "e"
            if word[-2..-1] == "le" and not le_except.include?(word)
                pass
            else
                disc += 1
            end
        end
    
        #4) check if consecutive vowels exists, triplets or pairs, count them as one.
        # doubleAndtripple = len(re.findall(r'[eaoui][eaoui]',word))
        doubleAndtripple = word.scan(/[eaoui][eaoui]/m).size
        # tripple          = len(re.findall(r'[eaoui][eaoui][eaoui]',word))
        tripple          = word.scan(/[eaoui][eaoui][eaoui]/m).size
        disc            += doubleAndtripple + tripple

        #5) count remaining vowels in word.
        numVowels = word.scan(/[eaoui]/m).size
            
        #6) add one if starts with "mc"
        syls += 1 if word[0..1] == "mc"
            
        #7) add one if ends with "y" but is not surrouned by vowel
        syls +=1 if word[-1] == "y" and not "aeoui".include?(word[-2])

        #8) add one if "y" is surrounded by non-vowels and is not in the last word.
        # for i, j in enumerate(word)
        word.split.each_with_index do |j, i| # check this loop
            if (i != 0) and (i != word.length-1)
                # if word[i-1] not in "aeoui" and word[i+1] not in "aeoui"
                if not "aeoui".include?(word[i-1]) and not "aeoui".include?(word[i+1])
                    syls += 1
                end
            end
        end
            
        #9) if starts with "tri-" or "bi-" and is followed by a vowel, add one.
        syls += 1 if word[0..2] == "tri" and "aeoui".include?(word[3])    
        syls += 1 if word[0..1] == "bi"  and "aeoui".include?(word[2])

        #10) if ends with "-ian", should be counted as two syllables, except for "-tian" and "-cian"
        if word[-3..-1] == "ian"
        #and (word[-4:] != "cian" or word[-4:] != "tian") :
            if word[-4..-1] == "cian" or word[-4..-1] == "tian"
                pass
             else
                syls += 1
            end
        end

        #11) if starts with "co-" and is followed by a vowel, check if exists in the double syllable dictionary, if not, check if in single dictionary and act accordingly.
        if word[0..1] == "co" and 'eaoui'.include(word[2])
            if co_two.include?(word[0..3]) or co_two.include?(word[0..4]) or co_two.include?(word[0..5])
                syls += 1
            elsif co_one.include(word[0..3]) or co_one.include?(word[0..4]) or co_one.include?(word[0..5])
                pass
            else
                syls += 1
            end
        end
        
        #12) if starts with "pre-" and is followed by a vowel, check if exists in the double syllable dictionary, if not, check if in single dictionary and act accordingly.
        if word[0..2] == "pre" and 'eaoui'.include?(word[3])
            if pre_one.include?(word[0..5])
                pass
            else
                syls += 1
            end
        end

        #13) check for "-n't" and cross match with dictionary to add syllable.
        negative = ["doesn't", "isn't", "shouldn't", "couldn't", "wouldn't"]
        if word[-3..-1] == "n't"
            if negative.include?(word)
                syls += 1
            else
                pass
            end
        end
        
        #14) Handling the exceptional words.
        disc += 1 if exception_del.include?(word) 
        syls += 1 if exception_add.include?(word)
             
        return numVowels - disc + syls
    end

    def syllables
        @@message1 = {}

        words      = params[:words].split
        words.each do |word|
            @@message1[word] = calculate_syllables(word)
        end

        redirect_to action: :display
    end

    def display
        @message1 = @@message1
    end
end