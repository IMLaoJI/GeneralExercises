package com.gildedrose

import org.scalacheck.Properties
import org.scalacheck.Prop.forAll
import Generators._

class SulfurasSpec extends Properties("Sulfuras"){

  property("Sulfuras Quality never decrese") = forAll(daysGen, sulfurasGen) {
    (days: Int, sulfuras: Item) => {
      val startingQualtity = sulfuras.quality
        (0 until days).map((_: Int) => {
          val result = GildedRose.updateQuality(Array(sulfuras))
          (result.length == 1 && result(0).quality == startingQualtity)
        }).forall(_ == true)
    }
  }
}
