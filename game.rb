require 'curses'
include Curses

init_screen
noecho

curs_set 0 

$title = 'Some Kind of Oregon Trail Game'

system('@title '+$title)

start_color
init_pair(COLOR_WHITE,COLOR_BLACK,COLOR_WHITE)
init_pair(COLOR_BLACK,COLOR_WHITE,COLOR_BLACK)

$game = {}

$screen = {
  :last => nil,
  :curr => :mainMenu,
  :options => {
    :mainMenu => {
      :type => :column,
      :length => 2,
      :selected => 0,
      :names => ['Play','Exit'],
      :func => ['startGame','exit']
    },
    :game => {
      :type => :grid,
      :length => 2,
      :width => 2,
      :selected => {x:0,y:0},
      :names => [['Info','Inventory'],['Crew','Continue']],
      :func => [['$game[:disp]=:info','$game[:disp]=:inv'],['$game[:disp]=:crew','continueGame']]
    },
    :lose => {
      :type => :button,
      :func => '$screen[:curr]=:mainMenu'
    },
    :win => {
      :type => :button,
      :func => '$screen[:curr]=:mainMenu'
    },
    :huntingYN => {
      :type => :line,
      :length => 2,
      :selected => 1,
      :names => ['Yes','No'],
      :func => ['startHunting','$screen[:curr]=:game']
    },
    :hunting => {
      :type => :gameMode
    },
    :shopYN => {
      :type => :line,
      :length => 2,
      :selected => 1,
      :names => ['Yes','No'],
      :func => ['startShopping','$screen[:curr]=:game']
    },
    :shop => {
      :type => :gameMode,
      :length => 3,
      :selected => 0,
      :names => ['Buy','Sell','Exit']
    }
  }
}

$items = {
  :rock => {
    :name => 'Rock',
    :tag => :rock,
    :type => :useless,
    :value => 0.15,
    :amt => 1,
    :desc => 'It is a rock.'
  },
  :gDrugs => {
    :name => 'Good Drugs',
    :tag => :gDrugs,
    :type => :consumable,
    :consumable => {
      :sick => :well,
      :health => 50
    },
    :value => 20,
    :amt => 1,
    :desc => 'These drugs cure basic illnesses, and do a body good.'
  },
  :mDrugs => {
    :name => 'Basic Drugs',
    :tag => :mDrugs,
    :type => :consumable,
    :consumable => {
      :sick => :well,
      :health => 0
    },
    :value => 17.5,
    :amt => 1,
    :desc => 'These drugs taste like cherries, and only cure diseases.'
  },
  :bDrugs => {
    :name => 'Bad Drugs',
    :tag => :bDrugs,
    :type => :consumable,
    :consumable => {
      :sick => :well,
      :health => -30
    },
    :value => 12,
    :amt => 1,
    :desc => 'These drugs get the job done, but at a cost.'
  },
  :food => {
    :name => 'Food',
    :tag => :food,
    :type => :food,
    :value => 2,
    :amt => 1,
    :desc => 'This nutritious... food... is uh.. good.. and you need it. May contain human flesh.'
  },
  :clock => {
    :name => 'Grandfather Clock',
    :tag => :clock,
    :type => :useless,
    :value => 2000,
    :amt => 1,
    :desc => 'This fine instrument tells you the exact hour on the hour. It plays a different song every 15 minutes. It reminds you of your grandparents\' home when you were but a wee lad.'
  },
  :hat => {
    :name => 'Fedora',
    :tag => :hat,
    :type => :consumable,
    :consumable => {
      :sick => :swag,
      :health => 5
    },
    :value => 15,
    :amt => 1,
    :desc => 'This fancy hat is actually a trilby, and does make you look cool.'
  },
  :ammo => {
    :name => 'Bullets',
    :tag => :ammo,
    :type => :ammo,
    :value => 3,
    :amt => 1,
    :desc => 'These bullets are used in your gun when hunting. Do not aim at face.'
  },
  :elixir => {
    :name => 'Elixir',
    :tag => :elixir,
    :type => :consumable,
    :consumable => {
      :sick => :elixir,
      :health => 100
    },
    :value => 100,
    :amt => 1,
    :desc => 'This rare medicine gives a person a genetically modified bacterial disease that prevents other diseases while boosting healing'
  },
}

$diseases = {
  :well => {
    :name => 'Well',
    :rarity => 0,
    :damage => -2,
  },
  :elixir => {
    :name => 'Great',
    :rarity => 0,
    :damage => -4,
  },
  :cholera => {
    :name => 'Cholera',
    :catch => '%s has gotten Cholera',
    :kill => '%s has died from Cholera',
    :rarity => 3,
    :damage => 3,
  },
  :fever => {
    :name => 'Mountain Fever',
    :catch => '%s has caught Mountain Fever',
    :kill => '%s has died from Mountain Fever',
    :rarity => 4,
    :damage => 2,
  },
  :dysentery => {
    :name => 'Dysentery',
    :catch => '%s has gotten Dysentery',
    :kill => '%s has died from Dysentery',
    :rarity => 2,
    :damage => 3,
  },
  :measels => {
    :name => 'Measels',
    :catch => '%s has got the Measels',
    :kill => '%s has died from the Measels',
    :rarity => 4,
    :damage => 2,
  },
  :gangrene => {
    :name => 'Gangrene',
    :catch => '%s has gotten Gangrene',
    :kill => '%s has died from Gangrene',
    :rarity => 3,
    :damage => 3,
  },
  :drugs => {
    :name => 'Drugged',
    :catch => '%s has been drugged',
    :kill => '%s has died from drugs',
    :rarity => 1,
    :damage => 8,
  },
  :swag => {
    :name => 'Pretty swaggen',
    :catch => '%s has become \'cool\'',
    :kill => '%s is kill',
    :rarity => 0,
    :damage => -1,
  }
  
}

def randomDisease
  chance = []
  num = 0
    $diseases.length.times { |i|
    d = $diseases.values[i]
    next if d[:rarity] <= 0
    num += d[:rarity]
    chance << [num,$diseases.keys[i]]
  }
  random = rand(0..400)
  chance.each { |a,d|
    return d if a > random
  }
  return nil
end

def startShopping
  $screen[:curr]=:shop
  list = $items.keys.shuffle[0..(rand(1...($items.length/2)))]
  $game[:shop][:list] = list.map{|k|[k,rand(3..20)]}
  $game[:shop][:cursor] = {x:0,y:0}
  opt[:selected] = $game[:shop][:cursor][:x]
  bool = false
  $game[:shop][:list].length.times { |i|
    k = $game[:shop][:list][i][0]
    if k == :food
      $game[:shop][:list][i][1] += rand(20..70)
      bool = true
    end
  }
  $game[:shop][:list] << [:food,rand(20..70)] if !bool
end

def getShopSelect
  pos = $game[:shop][:cursor]
  x = pos[:x]
  y = pos[:y]
  case x
  when 0
    return $game[:shop][:list][y]
  else
    item = $game[:inventory][y]
    item = [item[:tag],item[:amt]]
    return item
  end
end

def getShopList
  pos = $game[:shop][:cursor]
  x = pos[:x]
  y = pos[:y]
  case x
  when 0
    return $game[:shop][:list]
  else
    item = $game[:inventory].map{|i|[i[:tag],i[:amt]]}
    return item
  end
end

def getShopRange
  pos = $game[:shop][:cursor]
  x = pos[:x]
  y = pos[:y]
  case x
  when 0
    return $game[:shop][:list].length
  else
    return $game[:inventory].length
  end
end

def shopSelect
  pos = $game[:shop][:cursor]
  x = pos[:x]
  y = pos[:y]
  case x
  when 0
    select, count = getShopSelect
    item = $items[select]
    val = item[:value]
    if $game[:money] >= val
      $game[:money] -= val
      addItem(select,1)
      $game[:situation] << "Purchased #{item[:name]} for #{'$%.2f' % val}"
      bool = -1
      $game[:shop][:list].length.times { |i|
        k = $game[:shop][:list][i][0]
        if k == select
          $game[:shop][:list][i][1] -= 1
          bool = i if $game[:shop][:list][i][1] < 1
        end
      }
      $game[:shop][:list].delete_at(bool) if bool > -1
      clear
    end
  when 1
    select, count = getShopSelect
    item = $items[select]
    val = item[:value]*0.5
    if count > 0
      $game[:money] += val
      removeItem(select,1)
      bool = false
      $game[:shop][:list].length.times { |i|
        k = $game[:shop][:list][i][0]
        if k == select
          $game[:shop][:list][i][1] += 1
          bool = true
        end
      }
      $game[:shop][:list] << [select,1] if !bool
      $game[:situation] << "Sold #{item[:name]} for #{'$%.2f' % val}"
      clear
    end
  else
    $screen[:curr] = :game
  end
end

def startHunting
  $screen[:curr]=:hunting
  $game[:huntEnd] = Time.now.to_i + 10
  Thread.start {
    sleep(10)
    $screen[:curr]=:game
    addItem(:food,$game[:hunting][:score]*4)
    $game[:score] += $game[:hunting][:score] * 5
    $game[:situation] << "Hunted #{$game[:hunting][:score]} animals and got #{$game[:hunting][:score]*4}lb of food!"
  }
  $game[:hunting][:grid] = [['','',''],['','',''],['','','']]
  $game[:hunting][:curr] = {x:-1,y:-1}
  $game[:hunting][:prog] = 0
  $game[:hunting][:score] = 0
  3.times{addHuntingWord}
end

def huntingHasWord word
  return $game[:hunting][:grid].flatten.include?(word)
end

def addHuntingWord
  list = %w(BLAM KAPOW WHOOSH POP VROOM HACK YOLO RAM)
  list = list.shuffle
  list.each {|w| list.delete(w) if huntingHasWord(w)}
  return if list.length == 0
  word = list[0]
  loop { 
    x, y = rand(0..2), rand(0..2)
    if $game[:hunting][:grid][y][x].length == 0
      $game[:hunting][:grid][y][x] = word
      return
    end
  }
end

def gameHandlekey char
  case $screen[:curr]
  when :hunting
    return if itemCount(:ammo) == 0
    char = char.upcase
    prog = $game[:hunting][:prog]
    if prog == 0
      3.times { |y|
          3.times { |x|
            word = $game[:hunting][:grid][y][x]
            if word.start_with?(char)
              $game[:hunting][:prog] = 1
              $game[:hunting][:curr] = {x:x,y:y}
              return
            end
          }
        }
    else
      pos = $game[:hunting][:curr]
      prog = $game[:hunting][:prog]
      x, y = pos[:x], pos[:y]
      word = $game[:hunting][:grid][y][x]
      nextChr = word[prog]
      if char == nextChr
        $game[:hunting][:prog]+=1
        if $game[:hunting][:prog] >= word.length
          $game[:hunting][:grid][y][x] = ''
          $game[:hunting][:prog] = 0
          $game[:hunting][:score] += 1
          removeItem(:ammo)
          $game[:hunting][:curr] = {x:-1,y:-1}
          addHuntingWord
        end
      else
        $game[:hunting][:grid][y][x] = ''
        $game[:hunting][:prog] = 0
        removeItem(:ammo)
        $game[:hunting][:curr] = {x:-1,y:-1}
        addHuntingWord
      end
    end #if prog == 0

  when :shop
    height = getShopRange 
    case char
    when 'W','w'
      if $game[:shop][:cursor][:y] > 0
        $game[:shop][:cursor][:y] -= 1
        clear
      end
    when 'S','s'
      if $game[:shop][:cursor][:y] < height-1
        $game[:shop][:cursor][:y] += 1
        clear
      end
    when 'A','a'
      if $game[:shop][:cursor][:x] > 0
        $game[:shop][:cursor][:x] -= 1
        opt[:selected] = $game[:shop][:cursor][:x]
        clear
      end
    when 'D','d'
      if $game[:shop][:cursor][:x] < 2
        $game[:shop][:cursor][:x] += 1
        opt[:selected] = $game[:shop][:cursor][:x]
        clear
      end
    when ' '
      shopSelect

    end
    
  end #case $screen[:curr]
end #gameHandleKey

def log s
  f = File.open('log.txt','a')
  f.write(s.to_s+"\n")
  f.close()
end

def opt #treated as a variable shortener
  return $screen[:options][$screen[:curr]]
end

def white str #white lines
  attron(color_pair(COLOR_WHITE)){addstr(str)}
end

def baddstr str, val #boolean addstr, so I have white lines when they are selected
  if opt[:selected] == val
    white str
  else
    addstr str
  end
end

def startGame
  $screen[:curr] = :game
  $game = {
    :situation => ['You have started your journey'],
    :disp => :info,
    :progress => 0,
    :members => [
      {:name=>'Captain Danger',:health=>100,:sick=>:well},
      {:name=>'Major Tom',:health=>100,:sick=>:well},
      {:name=>'Roger Dodger',:health=>100,:sick=>:well},
      {:name=>'Buckaroo Bonzai',:health=>100,:sick=>:well},
      {:name=>'Han Solo',:health=>100,:sick=>:well}
    ],
    :inventory => [],
    :invSelect => 0,
    :invTarget => 0,
    :money => 50,
    :ammo => 0,
    :hunting => {},
    :shop => {},
    :score => 0,
    :scored => false
  }
  addItem(:food,50)
  addItem(:mDrugs,5)
  addItem(:ammo,20)

  continueGame

end

def situation
  $game[:members].length.times {|i|
    m = $game[:members][i]
    next if m[:sick] != :well
    disease = randomDisease
    unless disease.nil?
      $game[:situation] << $diseases[disease][:catch] % m[:name]
      m[:sick] = disease

    end
  }
end

def tick
  c = 0
  $game[:members].length.times {|i|
    m = $game[:members][i]
    well = m[:sick]
    if m[:health] <= 0
      c += 1
      next
    end
    damage = $diseases[well][:damage]
    if itemCount(:food) <= 0 && damage < 0
      m[:sick] = :well
      damage = 1
    end
    m[:health] -= damage
    m[:health] = 100 if m[:health] > 100
    if m[:health] <= 0
      $game[:situation] << $diseases[well][:kill] % m[:name]
      c += 1
    end
  }
  if c == 5
    $screen[:curr] = :lose
    return
  end
  return if $game[:progress] < 0.02
  if rand(0..15) == 0 && itemCount(:ammo) > 0
    $game[:situation] << 'You stumble into a hunting ground'
    $screen[:curr] = :huntingYN
    return
  end
  if rand(0..8) == 0
    item = $items.keys[rand(0...($items.length))]
    $game[:situation] << "You found an item: #{$items[item][:name]}"
    addItem item
    return
  end
  if rand(0..13) == 0
    $game[:situation] << 'You find a shop'
    $screen[:curr] = :shopYN
    return
  end
end

def continueGame
  $game[:disp] = :info
  $game[:situation] << 'The next day...'
  if itemCount(:food) > 0
    removeItem :food
  else
    $game[:situation] << 'You have run out of food.'
  end
  situation
  tick
  $game[:progress] += rand*0.0125+0.001
  if $game[:progress] > 1
    $game[:progress] = 1
    $screen[:curr] = :win
  end
end

def addItem item, count=1
  if $game[:inventory].length > 0
    $game[:inventory].length.times { |c|
      i = $game[:inventory][c]
      if i[:tag] === item
        i[:amt] += count
        return
      end
    }
  end
  newitem = $items[item]
  newitem[:amt] = count
  $game[:inventory] << newitem
end

def itemCount item
  if $game[:inventory].length > 0
    $game[:inventory].length.times { |c|
      i = $game[:inventory][c]
      return i[:amt] if i[:tag] === item
    }
  end
  return 0
end

def removeItem item, count=1
  if $game[:inventory].length > 0
    $game[:inventory].length.times { |c|
      i = $game[:inventory][c]
      if i[:tag] === item
        i[:amt] -= count
        $game[:inventory].delete_at(c) if i[:amt] <= 0
        return
      end
    }
  end
end

Thread.start {
  while(char = getch)
    if opt[:type] == :gameMode #handle hunting
      gameHandlekey char
    else
      case char
      when 'w','W'
        if opt[:type] == :column
          opt[:selected] -= 1 if opt[:selected] > 0
        elsif opt[:type] == :grid
          opt[:selected][:y] -= 1 if opt[:selected][:y] > 0
        end

      when 's','S'
        if opt[:type] == :column
          opt[:selected] += 1 if opt[:selected] < opt[:length]-1
        elsif opt[:type] == :grid
          opt[:selected][:y] += 1 if opt[:selected][:y] < opt[:length]-1
        end

      when 'a','A'
        if opt[:type] == :line
          opt[:selected] -= 1 if opt[:selected] > 0
        elsif opt[:type] == :grid
          opt[:selected][:x] -= 1 if opt[:selected][:x] > 0
        end

      when 'd','D'
        if opt[:type] == :line
          opt[:selected] += 1 if opt[:selected] < opt[:length]-1
        elsif opt[:type] == :grid
          opt[:selected][:x] += 1 if opt[:selected][:x] < opt[:width]-1
        end

      when 'r','R'
        if $game[:disp] == :inv && $game[:invSelect] > 0
          $game[:invSelect] -= 1
          clear
        end

      when 'f','F'
        if $game[:disp] == :inv && $game[:invSelect] < $game[:inventory].length-1
          $game[:invSelect] += 1
          clear
        end

      when 't','T'
        if $game[:disp] == :inv && $game[:invTarget] > 0
          $game[:invTarget] -= 1
        end

      when 'g','G'
        if $game[:disp] == :inv && $game[:invTarget] < 4
          $game[:invTarget] += 1
        end

      when 'e','E'
        if $game[:disp] == :inv && $game[:inventory][$game[:invSelect]][:type] == :consumable && $game[:members][$game[:invTarget]][:health] > 0
          item = $game[:inventory][$game[:invSelect]]
          target = $game[:members][$game[:invTarget]]
          heal = item[:consumable][:health]
          sick = item[:consumable][:sick]
          $game[:situation] << "Used #{item[:name]} on #{target[:name]}"
          removeItem item[:tag]
          target[:sick] = sick unless sick.nil?
          target[:health] += heal unless heal.nil?
          target[:health] = 100 if target[:health] > 100
          if target[:health] < 0
            $game[:situation] << "#{m[:name]} has died from #{item[:name]}"
            $game[:members].length.times {|i|
              m = $game[:members][i]
              if m[:health] <= 0
                c += 1
                next
              end
            }
            if c == 5
              $screen[:curr] = :lose
            end
          end
          clear
        end

      when ' '
        str = ''
        clear
        case opt[:type]
        when :grid
          str = opt[:func][opt[:selected][:y]][opt[:selected][:x]]
        when :column, :line
          str = opt[:func][opt[:selected]]
        when :button
          str = opt[:func]
        end

        eval(str)

      end # case char
    end #if gamem
  end #while
}

begin

  loop {
    
    if $screen[:curr] != $screen[:last]
      clear
      $screen[:last] = $screen[:curr]
    end

    case $screen[:curr]
    when :mainMenu #main menu
      setpos(2,0)
      addstr($title.center(80))

      opt[:length].times { |i| #drawing choices
        setpos(5+2*i,0)
        baddstr(opt[:names][i].center(80),i)
      }

    when :huntingYN

      setpos(4,0)
      white('Would you like to go hunting?'.center(80))
      setpos(5,0)
      addstr("(You have #{itemCount(:ammo)} ammo)")

      opt[:length].times { |i| #drawing choices
        setpos(8,40*i)
        baddstr(opt[:names][i].center(40),i)
      }

    when :hunting
      setpos(0,0)
      white('Type the words that appear below AS FAST AS POSSIBLE'.center(80))
      #setpos(1,0)
      #addstr($game[:hunting][:prog].to_s + ", "+$game[:hunting][:curr].to_s)
      setpos(24,0)
      white("  Time remaining: #{$game[:huntEnd]-Time.now.to_i}s".ljust(40)+"Ammo: #{itemCount(:ammo)}  ".rjust(40))

      3.times { |y|
        3.times { |x|
          setpos(y*(10)+2,x*26)
          word = $game[:hunting][:grid][y][x]
          if {x:x,y:y} == $game[:hunting][:curr]
            addstr(' '*(13-word.length/2.0).floor)
            prog = $game[:hunting][:prog]
            white(word[0...prog])
            addstr(word[prog..-1])
          else
            addstr(word.center(26))
          end
        }
      }

    when :lose #lose menu

      setpos(10,0)
      white('Everybody Died'.center(80))
      setpos(12,0)
      addstr('Press SPACE to go to the main menu'.center(80))

    when :win #win menu

      setpos(10,0)
      white('You made it to the end!'.center(80))
      setpos(11,0)
      if !$game[:scored]
        $game[:members].each { |m|
          $game[:score] += m[:health].to_i*2 if m[:health] > 0
        }
        $game[:score] += itemCount(:food).to_i
        $game[:score] += ($game[:money].to_i/2).round
      end
      $game[:scored] = true
      addstr("Final Score: #{$game[:score]}".center(80))
      setpos(12,0)
      addstr('Press SPACE to go to the main menu'.center(80))

    when :game #game menu
      setpos(0,0) #drawing progress
      progress = ?[ + (?=*((77*$game[:progress]).round) + ?>).ljust(78) + ?]
      white(progress)

      $game[:invSelect] = 0 if $game[:invSelect] > $game[:inventory].length

      case $game[:disp]
      when :crew
        setpos(3,0)
        addstr('Crew'.center(80))

        $game[:members].length.times { |i|
          m = $game[:members][i]
          setpos(i+5,0)
          white(m[:name].center(20))
          unless m[:health] <= 0
            addstr(('HEALTH '+m[:health].to_s).center(15))
            addstr(('SICKNESS '+$diseases[m[:sick]][:name]).center(20))
          else
            addstr('Dead'.center(60))
          end
        }
      when :inv
        setpos(3,0)
        addstr('Inventory'.center(80))

        setpos(17,0)
        white(' HELP ')
        addstr('  R/F - Item Selecting, T/G - Target Selecting')
        $game[:invSelect] = $game[:inventory].length-1 if $game[:invSelect] >= $game[:inventory].length
        #{:name=>'Rock',:value=>0.5,:amt=>1,:desc=>'It is a rock.'}
        selected = $game[:inventory][$game[:invSelect]]
        selected = {:name=>'Empty',:value=>0,:amt=>0,:type=>:useless,:desc=>''} if selected.nil?
                setpos(5,45)
        addstr('Name:'.ljust(10)+selected[:name].rjust(10))
        setpos(6,45)
        addstr('Value:'.ljust(10)+('$%.2f' % selected[:value]).rjust(10))
        setpos(7,45)
        addstr('Amount:'.ljust(10)+selected[:amt].to_s.rjust(10))
        setpos(8,45)
        addstr('Description:')
        words = selected[:desc].split(' ')
        lines = ['']
        words.each { |w|
          if w.length + lines[-1].length + 1 < 40
            lines[-1] += w + ' '
          else
            lines << w + ' '
          end
        }
        lines.length.times { |i|
          setpos(9+i,40)
          addstr(lines[i].center(40))
        }

        setpos(15,0)
        if selected[:type] == :consumable && $game[:members][$game[:invTarget]][:health] > 0
          white("Press E to use #{selected[:name]} on #{$game[:members][$game[:invTarget]][:name]} (#{$game[:members][$game[:invTarget]][:health]}/#{$diseases[$game[:members][$game[:invTarget]][:sick]][:name]})".center(80))
        else
          health = $diseases[$game[:members][$game[:invTarget]][:health]]
          addstr("You can not use #{selected[:name]} on #{$game[:members][$game[:invTarget]][:name]}".center(80))
        end

        $game[:inventory].length.times { |i|
          m = $game[:inventory][i]
          setpos(i+5,0)
          line = '['+m[:name].center(20)+']'
          if $game[:invSelect] == i
            white(line)
          else
            addstr(line)
          end

        }

      when :info

        setpos(3,0)
        addstr('News / Information'.center(80))

        count = $game[:situation].length > 11 && 11 || $game[:situation].length

        count.times { |i|
          line = $game[:situation][-1*(i+1)]
          setpos(5+i,0)
          addstr(('   '+line).ljust(80))
        }

      end #case $game[:disp]

      setpos(18,0) 
      white("  Money: #{'$%.2f' % $game[:money].to_f}  Food: #{itemCount(:food)}lb".ljust(80))

      opt[:length].times { |y| #drawing choices
        opt[:width].times { |x|
          setpos(19+y*3,x*40)
          baddstr(' '*40,{x:x,y:y})
          setpos(20+y*3,x*40)
          baddstr((opt[:names][y][x]).center(40),{x:x,y:y})
          setpos(21+y*3,x*40)
          baddstr(' '*40,{x:x,y:y})
        }
      }

    when :shopYN
      setpos(4,0)
      white('Would you like to enter the shop?'.center(80))
      setpos(5,0)
      addstr("(You have #{'$%.2f' % $game[:money]})")

      opt[:length].times { |i| #drawing choices
        setpos(8,40*i)
        baddstr(opt[:names][i].center(40),i)
      }

    when :shop
      setpos(3,0)
      addstr('Shop'.center(80))

      setpos(20,0)
      white(' HELP ')
      addstr('  WASD - Move cursor')

      #{:name=>'Rock',:value=>0.5,:amt=>1,:desc=>'It is a rock.'}
      $game[:shop][:cursor][:y] = getShopRange-1 if $game[:shop][:cursor][:y] >= getShopRange
      selected, count = getShopSelect
      valmult = $game[:shop][:cursor][:x] == 0 && 1 || 0.5
      if selected.nil?
        selected = {:name=>'Empty',:value=>0,:amt=>0,:type=>:useless,:desc=>''} 
      else
        it = $items[selected]
        selected = {:name=>it[:name],:value=>it[:value]*valmult,:amt=>count,:type=>it[:type],:desc=>it[:desc]}
      end
      setpos(5,45)
      addstr('Name:'.ljust(10)+selected[:name].rjust(10))
      setpos(6,45)
      addstr('Value:'.ljust(10)+('$%.2f' % selected[:value]).rjust(10))
      setpos(7,45)
      addstr('Amount:'.ljust(10)+selected[:amt].to_s.rjust(10))
      addstr(" (#{itemCount(it[:tag])} owned)") if $game[:shop][:cursor][:x] == 0
      setpos(8,45)
      addstr('Description:')
      words = selected[:desc].split(' ')
      lines = ['']
      words.each { |w|
        if w.length + lines[-1].length + 1 < 40
          lines[-1] += w + ' '
        else
          lines << w + ' '
        end
      }
      lines.length.times { |i|
        setpos(9+i,40)
        addstr(lines[i].center(40))
      }

      list = getShopList

      list.length.times { |i|
        tag, count = list[i]
        it = $items[tag]
        m = {:name=>it[:name],:value=>it[:value]*valmult,:amt=>count,:type=>it[:type],:desc=>it[:desc]}
        setpos(i+5,0)
        line = '['+m[:name].center(20)+']'
        if $game[:shop][:cursor][:y] == i
          white(line)
        else
          addstr(line)
        end

      }
      setpos(17,0)
      unless selected[:value] == 0
        if $game[:shop][:cursor][:x] == 0
          if $game[:money] >= selected[:value] 
            white("Press SPACE to purchase #{selected[:name]} for #{'$%.2f' % selected[:value]}".center(80))
          else
            addstr("You can not purchase #{selected[:name]} for #{'$%.2f' % selected[:value]}".center(80))
          end
        elsif $game[:shop][:cursor][:x] == 1
          white("Press SPACE to sell #{selected[:name]} for #{'$%.2f' % selected[:value]}".center(80))
        else
          white("Press SPACE to exit the shop".center(80))
        end
      end

      setpos(21,0) 
      white("  Money: #{'$%.2f' % $game[:money].to_f}  Food: #{itemCount(:food)}lb".ljust(80))
      opt[:length].times { |i| #drawing choices
        e = (i == 2 && 2 || 0)
        setpos(22,i*26)
        baddstr(' '*(26+e),i)
        setpos(23,i*26)
        baddstr((opt[:names][i]).center((26+e)),i)
        setpos(24,i*26)
        baddstr(' '*(26+e),i)
      }
    end #case $screen[:curr]

    sleep 0.01
    
    refresh
  }

ensure
  close_screen
end