import 'dart:io';
import 'dart:math';
import 'dart:collection';

base class SnakeSegment extends LinkedListEntry<SnakeSegment> {
  final Point<int> position;
  SnakeSegment(this.position);
}

void bersihkanLayar() {
  print("\x1B[2J\x1B[0;0H");
}

Future<void> jeda(int milidetik) async {
  await Future.delayed(Duration(milliseconds: milidetik));
}

int acak(int min, int max) {
  return min + Random().nextInt(max - min);
}

List<int> ukuranLayar() {
  return [stdout.terminalColumns, stdout.terminalLines];
}

void pindahKe(int baris, int kolom) {
  stdout.write('\x1B[${baris};${kolom}H');
}

class GameState {
  int lebarPermainan;
  int tinggiPermainan;
  LinkedList<SnakeSegment> ularKadal = LinkedList<SnakeSegment>();
  Point<int> makananUlar;
  Point<int> arahTerakhirKadal;

  GameState(this.lebarPermainan, this.tinggiPermainan) : 
    makananUlar = Point(acak(3, lebarPermainan), acak(3, tinggiPermainan)),
    arahTerakhirKadal = Point(1, 0) {
    int posisiAwalX = acak(3, lebarPermainan);
    int posisiAwalY = acak(3, tinggiPermainan);
    
    for (int i = 0; i < 5; i++) {
      ularKadal.add(SnakeSegment(Point(posisiAwalX - i, posisiAwalY)));
    }
  }

  void taruhMakanan() {
    do {
      makananUlar = Point(acak(3, lebarPermainan), acak(3, tinggiPermainan));
    } while (ularKadal.any((segment) => segment.position == makananUlar));
  }

  bool gerakkanKadal() {
    final kepalaKadal = ularKadal.first.position;

    Point<int>? langkahBerikutnya = cariLangkahBerikutnya(kepalaKadal, makananUlar);

    if (langkahBerikutnya != null) {
      ularKadal.addFirst(SnakeSegment(langkahBerikutnya));
      arahTerakhirKadal = Point(langkahBerikutnya.x - kepalaKadal.x, langkahBerikutnya.y - kepalaKadal.y);

      if (langkahBerikutnya.x < 0 || langkahBerikutnya.x >= lebarPermainan || 
          langkahBerikutnya.y < 0 || langkahBerikutnya.y >= tinggiPermainan || 
          ularKadal.skip(1).any((segment) => segment.position == langkahBerikutnya)) {
        return false;
      }

      if (langkahBerikutnya == makananUlar) {
        taruhMakanan();
      } else {
        ularKadal.remove(ularKadal.last);
      }
    }
    return true;
  }

  Point<int>? cariLangkahBerikutnya(Point<int> awal, Point<int> target) {
    List<Point<int>> arah = [
      Point(0, 1),
      Point(1, 0),
      Point(0, -1),
      Point(-1, 0)
    ];

    arah.removeWhere((dir) => dir == Point(-arahTerakhirKadal.x, -arahTerakhirKadal.y));

    Point<int>? langkahTerbaik;
    int jarakTerdekat = 9999;

    for (var arah in arah) {
      Point<int> posisiBaru = Point(awal.x + arah.x, awal.y + arah.y);

      if (posisiBaru.x >= 0 && posisiBaru.x < lebarPermainan && 
          posisiBaru.y >= 0 && posisiBaru.y < tinggiPermainan && 
          !ularKadal.any((segment) => segment.position == posisiBaru)) {
        int jarak = (posisiBaru.x - target.x).abs() + (posisiBaru.y - target.y).abs();
        if (jarak < jarakTerdekat) {
          jarakTerdekat = jarak;
          langkahTerbaik = posisiBaru;
        }
      }
    }

    if (langkahTerbaik == null) {
      Point<int> langkahMundur = Point(awal.x - arahTerakhirKadal.x, awal.y - arahTerakhirKadal.y);
      if (langkahMundur.x >= 0 && langkahMundur.x < lebarPermainan && 
          langkahMundur.y >= 0 && langkahMundur.y < tinggiPermainan) {
        langkahTerbaik = langkahMundur;
      }
    }

    return langkahTerbaik;
  }

  void gambarGrid() {
    bersihkanLayar();

    int i = 1;
    int posisiX = 0;
    int posisiY = 0;

    for (var segmen in ularKadal) {
      pindahKe(segmen.position.y + 1, segmen.position.x + 1);

      if (i == 2 || i == ularKadal.length - 1) {
        stdout.write('o');
        if (posisiX != segmen.position.x) {
          pindahKe(segmen.position.y + 2, segmen.position.x + 1);
          stdout.write('o');
          pindahKe(segmen.position.y + 3, segmen.position.x + 1);
          stdout.write('o');
          pindahKe(segmen.position.y, segmen.position.x + 1);
          stdout.write('o');
          pindahKe(segmen.position.y - 1, segmen.position.x + 1);
          stdout.write('o');
        } else {
          if (posisiY < segmen.position.y) {
            pindahKe(segmen.position.y + 1, segmen.position.x + 2);
            stdout.write('o');
            pindahKe(segmen.position.y + 1, segmen.position.x + 3);
            stdout.write('o');
            pindahKe(segmen.position.y + 1, segmen.position.x);
            stdout.write('o');
            pindahKe(segmen.position.y + 1, segmen.position.x - 1);
            stdout.write('o');
          } else {
            pindahKe(segmen.position.y + 1, segmen.position.x + 2);
            stdout.write('o');
            pindahKe(segmen.position.y + 1, segmen.position.x + 3);
            stdout.write('o');
            pindahKe(segmen.position.y + 1, segmen.position.x);
            stdout.write('o');
            pindahKe(segmen.position.y + 1, segmen.position.x - 1);
            stdout.write('o');
          }
        }
      } else {
        stdout.write('o');
      }
      posisiX = segmen.position.x;
      posisiY = segmen.position.y;
      i++;
    }

    pindahKe(ularKadal.first.position.y + 1, ularKadal.first.position.x + 1);
    stdout.write('o');

    pindahKe(makananUlar.y + 1, makananUlar.x + 1);
    stdout.write('[]');
  }
}

void main() async {
  List<int> dimensi = ukuranLayar();
  var gameState = GameState(dimensi[0] - 3, dimensi[1] - 3);
  
  bersihkanLayar();
  bool mulaiPermainan = true;
  bersihkanLayar();

  if (mulaiPermainan) {
    bersihkanLayar();
    stdin.echoMode = false;
    stdin.lineMode = false;

    while (true) {
      dimensi = ukuranLayar();
      gameState.lebarPermainan = dimensi[0] - 3;
      gameState.tinggiPermainan = dimensi[1] - 3;
      
      if (!gameState.gerakkanKadal()) {
        bersihkanLayar();
        print("Game is over!");
        break;
      }
      gameState.gambarGrid();
      await jeda(100);
    }
  }
}