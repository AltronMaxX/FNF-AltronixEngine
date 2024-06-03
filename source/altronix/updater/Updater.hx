package altronix.updater;

import haxe.io.Bytes;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Reader;
import sys.io.File;
import sys.io.Process;
#if sys
import sys.FileSystem;
#end

class Updater
{
  static final gameExtension:String = #if windows '.exe' #else '' #end;
  static final zipPath:String = Sys.getCwd() + '/engine.zip';
  static final updateTempPath:String = Sys.getCwd() + '/updateTemp/';
  static final curGameExePath:String = Sys.getCwd() + '/FNF-AE' + gameExtension;
  static final newGameExePath:String = Sys.getCwd() + '/updateTemp/FNF-AE' + gameExtension;

  /**
   * Updates game from downloaded archive.
   */
  public static function updateGame():Void
  {
    #if sys
    if (!FileSystem.exists(zipPath)) throw "Error while updating game! Zip file doesn't exist";

    FileSystem.createDirectory(updateTempPath);

    unzipGame();
    FileSystem.deleteFile(zipPath);
    replaceFiles();

    FileSystem.rename(curGameExePath, '${Path.withoutExtension(curGameExePath)}.bak');
    FileSystem.rename(newGameExePath, curGameExePath);

    new Process("FNF-AE" + gameExtension);
    FileSystem.deleteDirectory(updateTempPath);
    Sys.exit(0);
    #end
  }

  static function replaceFiles():Void
  {
    #if sys
    try
    {
      for (filePath in FileSystem.readDirectory(updateTempPath))
      {
        if (filePath == "FNF-AE" + gameExtension
          || filePath.endsWith(".dll")
          || filePath.endsWith(".ndll")) // TODO: Do something with dll, ndll
        {
          if (filePath == "FNF-AE" + gameExtension)
          {
            continue;
          }
          else
          {
            FileSystem.deleteFile(updateTempPath + filePath);
            continue;
          }
        }
        if (FileSystem.isDirectory(updateTempPath + filePath + '/'))
        {
          readDir(updateTempPath + filePath + '/');
          FileSystem.deleteDirectory(updateTempPath + filePath + '/');
        }
        else
        {
          var origFilePath = Sys.getCwd() + filePath;
          File.saveBytes(origFilePath, File.getBytes(updateTempPath + filePath));
          FileSystem.deleteFile(updateTempPath + filePath);
        }
      }
    }
    catch (e)
    {
      throw e;
    }
    #end
  }

  static function readDir(dir:String):Void
  {
    #if sys
    try
    {
      for (filePath in FileSystem.readDirectory(dir))
      {
        if (FileSystem.isDirectory(dir + filePath + '/'))
        {
          readDir(dir + filePath + '/');
          FileSystem.deleteDirectory(dir + filePath + '/');
        }
        else
        {
          var origFilePath = Sys.getCwd() + dir.split('updateTemp/')[1] + filePath;
          File.saveBytes(origFilePath, File.getBytes(dir + filePath));
          FileSystem.deleteFile(dir + filePath);
        }
      }
    }
    catch (e)
    {
      throw e;
    }
    #end
  }

  static function unzipGame():Void
  {
    #if sys
    var fields = new Reader(File.read(zipPath)).read();

    for (field in fields)
    {
      var isFolder = field.fileName.endsWith("/") && field.fileSize == 0;
      if (isFolder)
      {
        FileSystem.createDirectory('${updateTempPath}/${field.fileName}');
      }
      else
      {
        var split = [for (e in field.fileName.split("/")) e.trim()];
        split.pop();
        FileSystem.createDirectory('${updateTempPath}/${split.join("/")}');

        var data = unzip(field);
        File.saveBytes('${updateTempPath}/${field.fileName}', data);
      }
    }
    #end
  }

  static function unzip(f:Entry):Null<Bytes>
  {
    if (!f.compressed) return f.data;
    var c = new haxe.zip.Uncompress(-15);
    var s = haxe.io.Bytes.alloc(f.fileSize);
    var r = c.execute(f.data, 0, s, 0);
    c.close();
    if (!r.done || r.read != f.data.length || r.write != f.fileSize) throw "Invalid compressed data for " + f.fileName;
    f.compressed = false;
    f.dataSize = f.fileSize;
    f.data = s;
    return f.data;
  }
}
